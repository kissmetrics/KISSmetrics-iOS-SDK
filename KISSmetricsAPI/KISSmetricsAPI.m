//
// KISSmetricsSDK
//
// KISSmetricsAPI.m
//
// Copyright 2014 KISSmetrics
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.



#import "KMAMacros.c"
#import "KISSmetricsAPI.h"

// Define KISSmetricsAPI_options.m default values in case the customer has not opted to use a defaults file.
// In this case, the customer dev will need to initialize the KISSmetricsAPI with sharedAPIWithKey:(NSString*)
// in the Application Delegate's didFinishLaunchingWithOptions method.
NSString *kKMAAPIKey;
BOOL kKMARecordInstallations;
BOOL kKMARecordApplicationLifecycle;
BOOL kKMASetHardwareProperties;
BOOL kKMASetAppProperties;
BOOL kKMARecordViewControllerLifecycles;


// Import KISSmetricsAPI_options.h only AFTER default options definitions to allow for overwriting of values.
#import "KISSmetricsAPI_options.h"
#import "UIDevice+KMAHardware.h"
#import "KMAArchiver.h"
#import "KMAVerificationDelegateProtocol.h"
#import "KMAVerification.h"
#import "KMASender.h"
#import "KMATrackingOperations.h"
#import "KMATrackingOperations_NonTrackingState.h"
#import "KMATrackingOperations_TrackingState.h"


static NSInteger const kKMAFailsafeMaxVerificationDur = 1209600;
static KISSmetricsAPI  *sharedAPI = nil;
static KMAVerification *_verification;

// autoRecordInstalls events naming
static NSString *kKMAAppInstallEventName  = @"Installed App";
static NSString *kKMAAppUpdatedEventName  = @"Updated App";

// autoRecordAppLifecycle events naming
static NSString *kKMALaunchEventName      = @"Launched App";
static NSString *kKMABackgroundEventName  = @"App moved to background";
static NSString *kKMAActiveEventName      = @"App became active";
static NSString *kKMATerminatedEventName  = @"App terminated";

// autoSetAppProperties keys naming
static NSString *kKMABuildPropertkey   = @"App Build";
static NSString *kKMAVersionPropertKey = @"App Version";

// autoSetHardwareProperties keys naming
static NSString *kKMAManufacturerPropertyKey  = @"Device Manufacturer";
static NSString *kKMAPlatformPropertyKey      = @"Device Platform";
static NSString *kKMAModelPropertyKey         = @"Device Model";
static NSString *kKMASystemNamePropertyKey    = @"System Name";
static NSString *kKMASystemVersionPropertyKey = @"System Version";


@interface KISSmetricsAPI () <KMAVerificationDelegate>
@end


@implementation KISSmetricsAPI
{
  @private
    NSOperationQueue *_dataOpQueue, *_verificationQueue;
    KMASender *_sender;
    id <KMATrackingOperations> _trackingOperations;
}



#pragma mark self initialization methods

//-----
// load
//
// Discussion:
//
// Using the load method we can initialize the KISSmetricsAPI singleton prior to application launch.
// This allows us to attach listeners for application lifecycle events and pickup "applicationDidFinishLaunching"
// automatically.
//
// "In a custom implementation of load you can therefore safely message other
// unrelated classes from the same image, but any load methods implemented by
// those classes may not have run yet."
// http://developer.apple.com/library/Mac/#documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/Reference/Reference.html
//
// So we can message unrelated class, but we should not expect those unrelated
// classes to have run their load method. Simply don't do any work in the load
// method of any other KMA SDK classes.
//---
+ (void)load
{
    // Only if an API key has been supplied from the KISSmetricsAPI_options.h file
    if (kKMAAPIKey != NULL) {
        // The KISSmetricsAPI will self initialize using this API key
        [KISSmetricsAPI sharedAPIWithKey:kKMAAPIKey];
    }
}



#pragma mark Singleton Methods

+ (KISSmetricsAPI *) sharedAPIWithKey:(NSString *)apiKey
{
    @synchronized(self)
    {
        if (sharedAPI == nil) {
            sharedAPI = [[super allocWithZone:NULL] init];
            [sharedAPI initializeAPIWithKey:apiKey];
        }
    }
    return sharedAPI;
}


+ (KISSmetricsAPI *) sharedAPI
{
    @synchronized(self)
    {
        if (sharedAPI == nil) {
            KMALog(@"KISSMetricsAPI: WARNING - Returning nil object in sharedAPI as sharedAPIWithKey: has not been called.");
        }
    }
    return sharedAPI;
}


+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedAPI];
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (void) initializeAPIWithKey:(NSString *)apiKey
{
    KMALog(@"KISSmetricsAPI: init");
    KMALog(@"API_KEY = %@", apiKey);
    
    [KMAArchiver sharedArchiverWithKey:apiKey];
        
    // Initialize the queues
        
    // _dataOpQueue:
    // Handles all forwarded opertions received by the public methods to identify, alias, record, set...
    // This is so that we don't block the customer application's main thread and halt receipt of gestures,
    // animations or other main thread operations. Active threads may lock during Archive and Unarchive of the
    // queue via KMAArchiver .
    _dataOpQueue = [[NSOperationQueue alloc] init];
    [_dataOpQueue setMaxConcurrentOperationCount:2];
    [_dataOpQueue setName:@"KMADataOpQueue"];
    
    _sender = [[KMASender alloc] initDisabled:![[KMAArchiver sharedArchiver] getDoSend]];

    // Set initial TrackingOperations state
    if ([[KMAArchiver sharedArchiver] getDoTrack]) {
        _trackingOperations = [[KMATrackingOperations_TrackingState alloc] init];
    }
    else {
        _trackingOperations = [[KMATrackingOperations_NonTrackingState alloc] init];
    }
        
    // Ensure an Install UUID exists
    if (![[KMAArchiver sharedArchiver] getInstallUuid]) {
        [[KMAArchiver sharedArchiver] archiveInstallUuid:[self kma_generateID]];
    }
        
    // Ensure an identity exists
    if (![[KMAArchiver sharedArchiver] getIdentity]) {
        KMALog(@"KISSmetricsAPI - identity not set");
        [[KMAArchiver sharedArchiver] archiveFirstIdentity:[self kma_generateID]];
    }
        
    _verificationQueue = [self kma_verifiyForTracking];
    
    // KISSmetricsAPI_options.m defined options constants for automatic tracking
    if (kKMARecordApplicationLifecycle) {
        [sharedAPI kma_beginObservingAppLifecycle];
    }
    
    if (kKMASetHardwareProperties) {
        [sharedAPI autoSetHardwareProperties];
    }
    
    if (kKMASetAppProperties) {
        [sharedAPI autoSetAppProperties];
    }
    
    if (kKMARecordInstallations) {
        [sharedAPI autoRecordInstalls];
    }
}

- (void) forTesting
{
    // clear the verification queue first so that sending will be enabled if appropriate
    if (_verificationQueue) [_verificationQueue waitUntilAllOperationsAreFinished];
    if (_dataOpQueue) [_dataOpQueue waitUntilAllOperationsAreFinished];
    [_sender forTesting];
}


#pragma mark - sharedAPI public methods

- (void)identify:(NSString *)identity
{
    [_dataOpQueue addOperation:[_trackingOperations identifyOperationWithIdentity:identity
                                                                         archiver:[KMAArchiver sharedArchiver]
                                                                            kmapi:self]];
}


- (NSString *)identity
{
    return [[KMAArchiver sharedArchiver] getIdentity];
}


- (void)clearIdentity
{
    [_dataOpQueue addOperation:[_trackingOperations clearIdentityOperationWithNewIdentity:[self kma_generateID]
                                                                                 archiver:[KMAArchiver sharedArchiver]]];
}


- (void)alias:(NSString *)alias withIdentity:(NSString *)identity
{
    [_dataOpQueue addOperation:[_trackingOperations aliasOperationWithAlias:alias
                                                                   identity:identity
                                                                   archiver:[KMAArchiver sharedArchiver]
                                                                      kmapi:self]];
}


- (void)record:(NSString *)eventName
{
    [self record:eventName withProperties:nil];
}


- (void)record:(NSString *)eventName withProperties:(NSDictionary *)properties
{
    [_dataOpQueue addOperation:[_trackingOperations recordOperationWithName:eventName
                                                                 properties:properties
                                                                  condition:KMARecordAlways
                                                                   archiver:[KMAArchiver sharedArchiver]
                                                                      kmapi:self]];
}


// Deprecated method for record
- (void)recordEvent:(NSString *)eventName withProperties:(NSDictionary *)properties
{
    [self record:eventName withProperties:properties];
}


- (void)record:(NSString *)eventName withProperties:(NSDictionary *)properties onCondition:(KMARecordCondition)condition
{
    [_dataOpQueue addOperation:[_trackingOperations recordOperationWithName:eventName
                                                                 properties:properties
                                                                  condition:condition
                                                                   archiver:[KMAArchiver sharedArchiver]
                                                                      kmapi:self]];
}


- (void)record:(NSString *)eventName onCondition:(KMARecordCondition)condition
{
    [_dataOpQueue addOperation:[_trackingOperations recordOperationWithName:eventName
                                                                 properties:nil
                                                                  condition:condition
                                                                   archiver:[KMAArchiver sharedArchiver]
                                                                      kmapi:self]];
}


// Deprecated method for recordOnce
- (void)recordOnce:(NSString*)eventName
{
    [self record:eventName onCondition:KMARecordOncePerIdentity];
}


- (void)set:(NSDictionary *)properties
{
    [_dataOpQueue addOperation:[_trackingOperations setOperationWithProperties:properties
                                                                      archiver:[KMAArchiver sharedArchiver]
                                                                         kmapi:self]];
}


// Deprecated method for setProperties
- (void)setProperties:(NSDictionary *)properties
{
    [self set:properties];
}


- (void)setDistinct:(NSObject*)propertyValue forKey:(NSString*)propertyKey
{
    [_dataOpQueue addOperation:[_trackingOperations setDistinctOperationWithPropertyValue:propertyValue
                                                                                   forKey:propertyKey
                                                                                 archiver:[KMAArchiver sharedArchiver]
                                                                                    kmapi:self]];
}


- (void)autoRecordInstalls
{
    // If no value previously set, this is a new app install on the device.
    // We expect the keychain value to persist between app install, upgrade and uninstall. 
    if (![[KMAArchiver sharedArchiver] keychainAppVersion]) {
        [sharedAPI record:kKMAAppInstallEventName withProperties:nil onCondition:KMARecordOncePerInstall];
        [[KMAArchiver sharedArchiver] setKeychainAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    }
    else {
        // If the existing value doesn't match the current, this is an update.
        if (![[[KMAArchiver sharedArchiver] keychainAppVersion] isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]) {
            [sharedAPI record:kKMAAppUpdatedEventName];
            [[KMAArchiver sharedArchiver] setKeychainAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        }
    }
}


- (void)autoRecordAppLifecycle
{
    // Record application launch now, as it's too late to pick it up via NSNotificationCenter
    [sharedAPI record:kKMALaunchEventName];
    [sharedAPI kma_beginObservingAppLifecycle];
}


- (void)autoSetHardwareProperties
{
    // Recording 'Device Manufaturer' to keep properties consistent between iOS and other mobile devices/systems
    [[KISSmetricsAPI sharedAPI] setDistinct:@"Apple" forKey:kKMAManufacturerPropertyKey];

    // Device platform (iPhone, iPad)
    [[KISSmetricsAPI sharedAPI] setDistinct:[[UIDevice currentDevice] model] forKey:kKMAPlatformPropertyKey];
    
    // Device model (iPhone 5S, iPhone 5C)
    [[KISSmetricsAPI sharedAPI] setDistinct:[[UIDevice currentDevice] kmac_platformString] forKey:kKMAModelPropertyKey];
    
    // System Name (iOS)
    [[KISSmetricsAPI sharedAPI] setDistinct:[[UIDevice currentDevice] systemName] forKey:kKMASystemNamePropertyKey];
    
    // System Version (7.1)
    [[KISSmetricsAPI sharedAPI] setDistinct:[[UIDevice currentDevice] systemVersion] forKey:kKMASystemVersionPropertyKey];
}


- (void)autoSetAppProperties
{
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    [[KISSmetricsAPI sharedAPI] setDistinct:build forKey:kKMABuildPropertkey ];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [[KISSmetricsAPI sharedAPI] setDistinct:version forKey:kKMAVersionPropertKey];
}



# pragma mark Private methods

- (void)kma_beginObservingAppLifecycle
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kma_handleLaunch:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kma_handleBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kma_handleActivity:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kma_handleTermination:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}


- (NSString*)kma_generateID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return  (NSString *)CFBridgingRelease(string);
}


// Allows for injection of mock verification.
+ (void)kma_setVerification:(KMAVerification *)verification
{
    _verification = verification;
}


// Initializes the default connection if not set.
// Allows for injection of mock NSURLConnection within KMAConnection via method override.
+ (KMAVerification *)kma_verification
{
    if (!_verification) {
        _verification = [KMAVerification new];
    }
    
    return _verification;
}


- (void)kma_sendRecords
{
    [_sender startSending];
}


- (NSOperationQueue *) kma_verifiyForTracking
{
    // If not expired
    if ((NSInteger)[[NSDate date] timeIntervalSince1970] < [[[KMAArchiver sharedArchiver] getVerificationExpDate] intValue]) {
        return nil;
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Run verification in background thread
    [queue addOperationWithBlock:^{
        
        NSString *installUuid = [[KMAArchiver sharedArchiver] getInstallUuid];
        [[KISSmetricsAPI kma_verification] verifyTrackingForProductKey:[KMAArchiver sharedArchiver].key
                                                           installUuid:installUuid
                                                              delegate:self];
    }];
    
    return queue;
}



#pragma mark - iOS NSNotification Observer Methods

- (void)kma_handleLaunch:(NSNotification*)note
{
    [[KISSmetricsAPI sharedAPI] record:kKMALaunchEventName];
}

- (void)kma_handleBackground:(NSNotification*)note
{
    [[KISSmetricsAPI sharedAPI] record:kKMABackgroundEventName];
}

- (void)kma_handleActivity:(NSNotification*)note
{
    [[KISSmetricsAPI sharedAPI] record:kKMAActiveEventName];
}

- (void)kma_handleTermination:(NSNotification *)note
{
    [[KISSmetricsAPI sharedAPI] record:kKMATerminatedEventName];
}



# pragma mark - KMAVerificationDelegate methods

- (void)verificationSuccessful:(BOOL)success
                       doTrack:(BOOL)doTrack
                       baseUrl:(NSString*)baseUrl
                expirationDate:(NSNumber*)expirationDate
{
    if (!success) {

        _trackingOperations = [[KMATrackingOperations_TrackingState alloc] init];
        [[KMAArchiver sharedArchiver] archiveDoTrack:YES];
        
        [_sender disableSending];
        [[KMAArchiver sharedArchiver] archiveDoSend:NO];

        return;
    }
    
    NSNumber *maxExpiration = @([[NSDate date] timeIntervalSince1970] + kKMAFailsafeMaxVerificationDur);
    NSNumber *expDate = MIN(expirationDate, maxExpiration);
    [[KMAArchiver sharedArchiver] archiveVerificationExpDate:expDate];
    
    if (!doTrack) {
        _trackingOperations = [[KMATrackingOperations_NonTrackingState alloc] init];
        
        // Clear the send queue. Any archived records will be discarded and not sent.
        [[KMAArchiver sharedArchiver] clearSendQueue];
    }
    else {
        _trackingOperations = [[KMATrackingOperations_TrackingState alloc] init];
        
        // If we should be tracking, then we should should be sending...
        [_sender enableSending];
        [[KMAArchiver sharedArchiver] archiveDoSend:YES];
    }
    
    [[KMAArchiver sharedArchiver] archiveDoTrack:doTrack];
    [[KMAArchiver sharedArchiver] archiveBaseUrl:baseUrl];
}



#pragma mark Private Unit Testing Helpers

// + sharedAPIInitialized
//
// private static method for unit testing the on load self initialization of the SDK.
// This private method is exposed publicly within a category for testing.
+ (BOOL)uth_sharedAPIInitialized
{
    return sharedAPI != nil;
}

// These empty methods my be swizzled in tests to pick up nsi_recursiveSend activity with tests.
- (void)uth_testRequestSuccessful{}
- (void)uth_testRequestReceivedError{}
- (void)uth_testRequestReceivedUnexpectedStatusCode{}

@end



#pragma mark KISSMetricsAPI - deprecated

// KISSMetricsAPI is deprecated
// All methods will forward to KISSmetricsAPI
@implementation KISSMetricsAPI

+ (KISSmetricsAPI *)sharedAPIWithKey:(NSString *)apiKey {
    return [KISSmetricsAPI sharedAPIWithKey:apiKey];
}

+ (KISSmetricsAPI *)sharedAPI {
    return [KISSmetricsAPI sharedAPI];
}

- (void)recordEvent:(NSString *)eventName withProperties:(NSDictionary *)properties {
    [[KISSmetricsAPI sharedAPI] record:eventName withProperties:properties];
}

- (void)setProperties:(NSDictionary *)properties {
    [[KISSmetricsAPI sharedAPI] set:properties];
}

- (void)identify:(NSString *)identity {
    [[KISSmetricsAPI sharedAPI] identify:identity];
}

- (NSString *)identity {
    return [[KISSmetricsAPI sharedAPI] identity];
}

- (void)clearIdentity {
    [[KISSmetricsAPI sharedAPI] clearIdentity];
}

- (void)alias:(NSString *)firstIdentity withIdentity:(NSString *)secondIdentity {
    [[KISSmetricsAPI sharedAPI] alias:firstIdentity withIdentity:secondIdentity];
}


@end
