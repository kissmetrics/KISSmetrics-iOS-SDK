//
// KISSmetricsSDK
//
// KMAArchiver.m
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
#import "KMAKeychainItemWrapper.h"
#import "KMAQueryEncoder.h"
#import "KMAArchiver.h"


static NSInteger  const kKMASchemaVersion = 2;
static NSInteger  const kKMASchemaVersionDefault = 1;
static NSInteger  const kKMAVerificationExpDateDefault = 0;
static BOOL       const kKMAHasGenericIdentityDefault = NO;
static BOOL       const kKMADoTrackDefault = YES;
static BOOL       const kKMADoSendDefault = NO;
static NSString * const kKMASchemaVersionKey = @"schemaVersion";
static NSString * const kKMAInstallUuidKey = @"installUuid";
static NSString * const kKMAHasGenericIdentityKey = @"hasGenericIdentity";
static NSString * const kKMAVerificationExpDateKey = @"verificationExpDate";
static NSString * const kKMADoTrackKey = @"doTrack";
static NSString * const kKMADoSendKey = @"doSend";
static NSString * const kKMABaseUrlKey = @"baseUrl";
static NSString * const kKMABaseUrlDefault = @"https://trk.kissmetrics.com";
static NSString * const kKMAAPIClientType  = @"mobile_app";
static NSString * const kKMAAPIUserAgent   = @"kissmetrics-ios/2.0.1";
static NSString * const kKMAKeychainAppVersionKey = @"KMAAppVersion";

static KMAArchiver *sSharedArchiver = nil;


@interface KMAArchiver ()

  @property (nonatomic, strong) NSURL *actionsUrl;
  @property (nonatomic, strong) NSURL *identityUrl;
  @property (nonatomic, strong) NSURL *settingsUrl;
  @property (nonatomic, strong) NSURL *savedIdEventsUrl;
  @property (nonatomic, strong) NSURL *savedInstallEventsUrl;
  @property (nonatomic, strong) NSURL *savedPropertiesUrl;
  @property (nonatomic, strong) KMAQueryEncoder *queryEncoder;
  @property (nonatomic, strong) NSMutableArray *sendQueue;
  @property (nonatomic, strong) NSString *identity;
  @property (nonatomic, strong) NSMutableDictionary *settings;
  @property (nonatomic, strong) NSMutableArray *savedIdEvents;
  @property (nonatomic, strong) NSMutableArray *savedInstallEvents;
  @property (nonatomic, strong) NSMutableDictionary *savedProperties;


  // Private methods
  - (NSURL *)kma_libraryUrlWithPathComponent:(NSString *)pathComponent;
  - (BOOL)kma_directoryExistsAtUrl:(NSURL *)dirUrl;
  - (void)kma_createLibraryDirectoryAtURL:(NSURL *)dirUrl;
  - (BOOL)kma_addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
  - (void)kma_defineDefaultUrls;
  - (void)kma_migrateFromVersion:(NSInteger)fromVersion toVersion:(NSInteger)toVersion;

  - (void)kma_unarchiveSettings;
  - (void)kma_archiveDefaultSettings;
  - (void)kma_archiveSettings;

  - (void)kma_unarchiveIdentity;

  - (void)kma_unarchiveSavedIdEvents;
  - (void)kma_archiveSavedIdEvents;

  - (void)kma_unarchiveSavedInstallEvents;
  - (void)kma_archiveSavedInstallEvents;

  - (void)kma_unarchiveSavedProperties;
  - (void)kma_archiveSavedProperties;

  - (void)kma_unarchiveSendQueue;
  - (void)kma_archiveSendQueue;

@end


@implementation KMAArchiver

@synthesize keychainAppVersion;



#pragma mark Singleton Methods

+ (KMAArchiver *)sharedArchiverWithKey:(NSString *)apiKey
{
    @synchronized(self)
    {
        if (sSharedArchiver == nil) {
            sSharedArchiver = [[super allocWithZone:NULL] init];
            sSharedArchiver.key = apiKey;
            sSharedArchiver.queryEncoder = [[KMAQueryEncoder alloc] initWithKey:sSharedArchiver.key
                                                                      clientType:kKMAAPIClientType
                                                                       userAgent:kKMAAPIUserAgent];
        }
    }
    return sSharedArchiver;
}


+ (id)sharedArchiver
{
    @synchronized(self)
    {
        if (sSharedArchiver == nil) {
            KMALog(@"KISSmetricsAPI: WARNING - Returning nil object in sharedArchiver as sharedArchiverWithKey: has not been called.");
        }
    }
    return sSharedArchiver;
}


+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedArchiver];
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}


- (id)init
{
    if ((self = [super init])) {
        KMALog(@"------------------KMAArchiver init");
        
        // Ensure Library URL exists
        if (![self kma_directoryExistsAtUrl:[self kma_libraryUrlWithPathComponent:@"KISSmetrics"]]) {
            [self kma_createLibraryDirectoryAtURL:[self kma_libraryUrlWithPathComponent:@"KISSmetrics"]];
        }
        
        [self kma_defineDefaultUrls];
        [self kma_unarchiveSettings];
        
        // Perform any required migrations base on settings values (schemaVersion)
        [self kma_migrateFromVersion:[self getSchemaVersion] toVersion:kKMASchemaVersion];
        
        [self kma_unarchiveIdentity];
        [self kma_unarchiveSendQueue];
        [self kma_unarchiveSavedIdEvents];
        [self kma_unarchiveSavedInstallEvents];
        [self kma_unarchiveSavedProperties];
        
        [self keychainAppVersion];
    }
    
    return self;
}



#pragma mark - file management

- (NSURL *)kma_libraryUrlWithPathComponent:(NSString *)pathComponent
{
    NSURL *libraryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                                inDomains:NSUserDomainMask] lastObject];
    NSURL *componentURL = [libraryURL URLByAppendingPathComponent:pathComponent];
    return componentURL;
}


- (BOOL)kma_directoryExistsAtUrl:(NSURL *)dirUrl
{
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dirUrl.path isDirectory:&isDir];
    
    if (exists && isDir) {
        return YES;
    }
    return NO;
}


- (void)kma_createLibraryDirectoryAtURL:(NSURL *)dirUrl
{
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:dirUrl.path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        KMALog(@"KISSmetricsAPI_Archiver - !WARNING! - KISSmetrics library directory could not be created");
        return;
    }
    
    // Prevent iCloud backup
    [self kma_addSkipBackupAttributeToItemAtURL:dirUrl];
}


// Compatible with iOS 5.1+ it isn't possible to exclude backups on iOS 5.0
- (BOOL)kma_addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if (!success) {
        KMALog(@"KISSmetricsAPI_Archiver - !WARNING! - KISSmetrics library directory could not be excluded from backup");
    }
    return success;
}


- (void)kma_defineDefaultUrls
{
    self.actionsUrl = [self kma_libraryUrlWithPathComponent:@"KISSmetrics/actions.kma"];
    self.identityUrl = [self kma_libraryUrlWithPathComponent:@"KISSmetrics/identity.kma"];
    self.settingsUrl = [self kma_libraryUrlWithPathComponent:@"KISSmetrics/settings.kma"];
    self.savedIdEventsUrl = [self kma_libraryUrlWithPathComponent:@"KISSmetrics/savedEvents.kma"];
    self.savedInstallEventsUrl = [self kma_libraryUrlWithPathComponent:@"KISSmetrics/savedInstallEvents.kma"];
    self.savedPropertiesUrl = [self kma_libraryUrlWithPathComponent:@"KISSmetrics/savedProperties.kma"];
}


- (void)kma_migrateFromVersion:(NSInteger)fromVersion toVersion:(NSInteger)toVersion
{
    @synchronized(self)
    {
        switch (fromVersion + 1) {
            
            case 2: {
                KMALog(@"KISSmetricsAPI_Archiver - migrating from v1 to v2");
                
                // Migrating from v1 to v2:
                // The v1 SDK stored the identity archive directly to the NSLibrary dir.
                // Version 2 stores all archive files under a KISSmetrics directory in the NSLibrary dir.
                // There is no need to migrate the v1 actions archive from the caches directory as it will have been
                // removed during the app update which applies the Version 2 SDK.
            
                NSString *oldIdentityPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
                                             stringByAppendingPathComponent:@"KISSMetrics.identity"];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:oldIdentityPath]) {
                
                    NSError *moveError;
                    [[NSFileManager defaultManager] copyItemAtPath:oldIdentityPath
                                                            toPath:self.identityUrl.path
                                                             error:&moveError];
                    if (!moveError) {
                        [self kma_archiveSchemaVersion:@(2)];
                        [[NSFileManager defaultManager] removeItemAtPath:oldIdentityPath error:nil];
                    }
                }
                else {
                    // Nothing to change
                    [self kma_archiveSchemaVersion:@(2)];
                }
            }
        }
    }
}



#pragma mark - sharedArchiver public methods (public methods of a framework private class)

- (void)archiveInstallUuid:(NSString *)installUuid
{
    // Protect from null or emtpy string, or overriding UUID value
    if (installUuid == nil ||
        installUuid.length == 0 ||
        [self.settings objectForKey:kKMAInstallUuidKey]) {
        
        KMALog(@"KISSmetricsAPI_Archiver - !WARNING! - installUuid not valid to save");
        return;
    }
    
    @synchronized(self)
    {
        [self.settings setObject:installUuid forKey:kKMAInstallUuidKey];
        [self kma_archiveSettings];
    }
}


- (void)archiveDoTrack:(BOOL)doTrack
{
    @synchronized(self)
    {
        [self.settings setObject:@(doTrack) forKey:kKMADoTrackKey];
        [self kma_archiveSettings];
    }
}


- (void)archiveDoSend:(BOOL)doSend
{
    @synchronized(self)
    {
        [self.settings setObject:@(doSend) forKey:kKMADoSendKey];
        [self kma_archiveSettings];
    }
}


- (void)archiveBaseUrl:(NSString *)baseUrl
{
    @synchronized(self)
    {
        [self.settings setObject:baseUrl forKey:kKMABaseUrlKey];
        [self kma_archiveSettings];
    }
}


- (void)archiveVerificationExpDate:(NSNumber *)expDate
{
    @synchronized(self)
    {
        [self.settings setObject:expDate forKey:kKMAVerificationExpDateKey];
        [self kma_archiveSettings];
    }
}


- (void)archiveHasGenericIdentity:(BOOL)hasGenericIdentity
{
    @synchronized(self)
    {
        [self.settings setObject:@(hasGenericIdentity) forKey:kKMAHasGenericIdentityKey];
        [self kma_archiveSettings];
    }
}


// Replaces _sendQueue with a new(empty) Array
- (void)clearSendQueue
{
    @synchronized(self)
    {
        self.sendQueue = [NSMutableArray array];
        [self kma_archiveSendQueue];
    }
}


// Replaces _savedIdEvents with a new(empty) Array
- (void)clearSavedIdEvents
{
    @synchronized(self)
    {
        self.savedIdEvents = [NSMutableArray array];
        [self kma_archiveSavedIdEvents];
    }
}


// Replaces _savedProperties with a new(empty) Dictionary
- (void)clearSavedProperties
{
    @synchronized(self)
    {
        self.savedProperties = [NSMutableDictionary dictionary];
        [self kma_archiveSavedProperties];
    }
}


- (void)archiveFirstIdentity:(NSString*)firstIdentity
{
    if (firstIdentity == nil || firstIdentity.length == 0) {
        return;
    }
    
    @synchronized(self)
    {
        KMALog(@"archiveFirstIdentity");
        self.identity = firstIdentity;
        [self archiveHasGenericIdentity:YES];
        if (![NSKeyedArchiver archiveRootObject:self.identity toFile:self.identityUrl.path]) {
            KMALog(@"KISSmetricsAPI_Archiver - !WARNING! - Unable to archive identity");
        }
    }
}


- (NSString*)getIdentity
{
    // Not sychronized to prevent locking of the calling thread.
    KMALog(@"KMAArchiver getIdentity");
    return self.identity;
}


- (NSString*)getQueryStringAtIndex:(NSInteger)index
{
    @synchronized(self)
    {
        KMALog(@"KMAArchiver getQueryStringAtIndex");
        if (self.sendQueue && self.sendQueue.count > index) {
            return[self.sendQueue objectAtIndex:index];
        }
    }
    return nil;
}


- (void)removeQueryStringAtIndex:(NSInteger)index
{
    @synchronized(self)
    {
        KMALog(@"KMAArchiver removeFirstRecord");
        if (self.sendQueue.count > index) {
            [self.sendQueue removeObjectAtIndex:index];
            [self kma_archiveSendQueue];
        }
    }
}


- (NSUInteger)getQueueCount
{
    @synchronized(self)
    {
        KMALog(@"KMAArchiver getQueueCount");
        return (NSUInteger)self.sendQueue.count;
    }
}


- (void)archiveEvent:(NSString *)name withProperties:(NSDictionary *)properties onCondition:(KMARecordCondition)condition
{
    KMALog(@"KMAArchiver archiveEvent withProperties onCondition");
    
    if (name == nil || [name length] == 0) {
        KMALog(@"KISSmetricsAPI - !WARNING! - Tried to record event with empty or nil name. Ignoring.");
        return;
    }
    
    switch (condition) {
        case KMARecordAlways:
            // Nothing else to check, continue with archiving the event.
            break;
                
        case KMARecordOncePerIdentity:
            
            @synchronized(self)
            {
                if ([self.savedIdEvents containsObject:name]) {
                    return;
                }
                else {
                    [self.savedIdEvents addObject:name];
                    [self kma_archiveSavedIdEvents];
                }
            }
            
            break;
                
        case KMARecordOncePerInstall:

            @synchronized(self)
            {
                if ([self.savedInstallEvents containsObject:name]) {
                    return;
                }
                else {
                    [self.savedInstallEvents addObject:name];
                    [self kma_archiveSavedInstallEvents];
                }
            }

            break;
        
        default:
            // Continue with archiving the event.
            break;
    }
    
    // Intentionally called outside of @synchronized, method is already synchronized
    [self archiveEvent:name withProperties:properties];
}


- (void)archiveEvent:(NSString *)name withProperties:(NSDictionary *)properties
{
    KMALog(@"KMAArchiver archiveEvent withProperties");
    
    @synchronized(self)
    {
        // We'll store and use the actual time of the record event in case of disconnected operation.
        int actualTimeOfEvent = (int)[[NSDate date] timeIntervalSince1970];
        
        NSString *theUrl = [self.queryEncoder createEventQueryWithName:name
                                                            properties:properties
                                                              identity:self.identity
                                                             timestamp:actualTimeOfEvent];
        // Queue up call
        [self.sendQueue addObject:theUrl];
        
        // Persist the new queue
        [self kma_archiveSendQueue];
    }
}



- (void)archiveProperties:(NSDictionary *)properties
{
    KMALog(@"archiveProperties");
    
    if (properties == nil || [properties count] == 0) {
        KMALog(@"KISSmetricsAPI - !WARNING! - Tried to set properties with no properties in it..");
        return;
    }
    
    @synchronized(self)
    {
        int actualTimeOfEvent = (int)[[NSDate date] timeIntervalSince1970];
        
        NSString *theUrl = [self.queryEncoder createPropertiesQueryWithProperties:properties
                                                                          identity:self.identity
                                                                         timestamp:actualTimeOfEvent];
        [self.sendQueue addObject:theUrl];
        [self kma_archiveSendQueue];
    }
}


- (void)archiveIdentity:(NSString *)identity
{
    KMALog(@"KMAArchiver archiveIdentity");
    
    if (identity == nil || [identity length] == 0 || identity == self.identity) {
        KMALog(@"KISSmetricsAPI - !WARNING! - attempted to use nil, empty or existing identity. Ignoring.");
        return;
    }
    
    NSString *theUrl = [self.queryEncoder createAliasQueryWithAlias:identity andIdentity:self.identity];
    
    @synchronized(self)
    {
        self.identity = identity;
        
        if (![NSKeyedArchiver archiveRootObject:self.identity toFile:self.identityUrl.path]) {
            KMALog(@"KISSmetricsAPI - !WARNING! - Unable to archive new identity!");
        }
        
        // Only add the alias query if the current identity is a generic identity
        if ([self hasGenericIdentity]) {
            [self archiveHasGenericIdentity:NO];
            [self.sendQueue addObject:theUrl];
            [self kma_archiveSendQueue];
        }
        else {
            // This is expected to be an entirely different user.
            // Clear saved Events and Properties just as we would when clearing an Identity
            [self clearSavedIdEvents];
            [self clearSavedProperties];
        }
    }
}


- (void)archiveAlias:(NSString *)alias withIdentity:(NSString *)identity
{
    KMALog(@"KMAArchiver archiveAlias");
    
    if (alias == nil || [alias length] == 0 || identity == nil || [identity length] == 0) {
        KMALog(@"KISSmetricsAPI - !WARNING! - attempted to use nil or empty identities in alias (%@ and %@). Ignoring.",
               alias, identity);
        return;
    }

    NSString *theUrl = [self.queryEncoder createAliasQueryWithAlias:alias andIdentity:identity];
    
    @synchronized(self)
    {
        [self.sendQueue addObject:theUrl];
        [self kma_archiveSendQueue];
    }
}

- (void)archiveDistinctProperty:(NSString*)name value:(NSObject*)value
{
    NSString *valueString;
    
    // Confirm value is of type NSString or NSNumber
    if ([value isKindOfClass:[NSString class]]) {
        valueString = (NSString*)value;
    }
    else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *valueNumber = (NSNumber *)value;
        valueString = [valueNumber stringValue];
    }
    else {
        KMALog(@"KISSmetricsAPI - !WARNING! - Property values must be NSString or NSNumber objects!");
        return;
    }
    
    @synchronized(self)
    {
        // All property values are archived as NSStrings
        NSString *propertyValue = [self.savedProperties objectForKey:name];

        if ([propertyValue isEqualToString:valueString]) {
            return;
        } else {
            // Archive the NSString value of the NSString or NSNumber property.
            [self.savedProperties addEntriesFromDictionary:@{name:valueString}];
            [self kma_archiveSavedProperties];
        }
    }
    
    [self archiveProperties:@{name:valueString}];
}


- (NSInteger)getSchemaVersion {
    return [[self.settings objectForKey:kKMASchemaVersionKey] integerValue];
}


- (NSString *)getInstallUuid {
    return (NSString *)[self.settings objectForKey:kKMAInstallUuidKey];
}


- (NSNumber *)getVerificationExpDate
{
    if ([self.settings objectForKey:kKMAVerificationExpDateKey]) {
        return [self.settings objectForKey:kKMAVerificationExpDateKey];
    }
    
    return @(kKMAVerificationExpDateDefault);
}


- (BOOL)hasGenericIdentity
{
    if ([self.settings objectForKey:kKMAHasGenericIdentityKey]) {
        return [[self.settings objectForKey:kKMAHasGenericIdentityKey] boolValue];
    }
    
    return kKMAHasGenericIdentityDefault;
}


- (BOOL)getDoSend
{
    if ([self.settings objectForKey:kKMADoSendKey]) {
        return [[self.settings objectForKey:kKMADoSendKey] boolValue];
    }
    
    return kKMADoSendDefault;
}


- (BOOL)getDoTrack
{
    if ([self.settings objectForKey:kKMADoTrackKey]) {
        return [[self.settings objectForKey:kKMADoTrackKey] boolValue];
    }
    
    return kKMADoTrackDefault;
}


- (NSString *)getBaseUrl
{
    if ([self.settings objectForKey:kKMABaseUrlKey]) {
        return (NSString *)[self.settings objectForKey:kKMABaseUrlKey];
    }
    
    return (NSString *)kKMABaseUrlDefault;
}



#pragma mark - sharedArchiver private methods

- (void)kma_archiveSchemaVersion:(NSNumber *)schemaVersion
{
    @synchronized(self)
    {
        [self.settings setObject:schemaVersion forKey:kKMASchemaVersionKey];
        [self kma_archiveSettings];
    }
}


- (void)kma_unarchiveSettings
{
    // Not @synch'ed as should always be called inside @sync bloc
    self.settings = [NSKeyedUnarchiver unarchiveObjectWithFile:self.settingsUrl.path];
    if (!self.settings) {
        [self kma_archiveDefaultSettings];
    }
}


- (void)kma_archiveDefaultSettings
{
    // Not @synch'ed as should only be called on init
    self.settings = [@{kKMASchemaVersionKey: @(kKMASchemaVersionDefault),
                       kKMADoTrackKey: @(kKMADoTrackDefault),
                       kKMADoSendKey:  @(kKMADoSendDefault),
                       kKMABaseUrlKey: kKMABaseUrlDefault,
                       kKMAVerificationExpDateKey: @(kKMAVerificationExpDateDefault),
                       kKMAHasGenericIdentityKey: @(kKMAHasGenericIdentityDefault)} mutableCopy];
    
    [self kma_archiveSettings];
}


- (void)kma_archiveSettings
{
    // Not @synch'ed as should always be called inside @sync bloc
    if (![NSKeyedArchiver archiveRootObject:self.settings toFile:self.settingsUrl.path]) {
        KMALog(@"KISSmetricsAPI - !WARNING! - Unable to archive settings!");
    }
}


- (void)kma_unarchiveIdentity
{
    //Only ever called on init which shouldn't need to block
    self.identity = [NSKeyedUnarchiver unarchiveObjectWithFile:self.identityUrl.path];
}


- (void)kma_archiveSavedIdEvents
{
    // Not @synch'ed as should always be called inside @sync bloc
    if (![NSKeyedArchiver archiveRootObject:self.savedIdEvents toFile:self.savedIdEventsUrl.path]) {
        KMALog(@"KISSmetricsAPI - !WARNING! - Unable to archive savedIdEvents!");
    }
}


- (void)kma_unarchiveSavedIdEvents
{
    // Not @synch'ed as should always be called inside @sync bloc
    self.savedIdEvents = [NSKeyedUnarchiver unarchiveObjectWithFile:self.savedIdEventsUrl.path];
    if (!self.savedIdEvents) {
        self.savedIdEvents = [NSMutableArray array];
    }
}


- (void)kma_archiveSavedInstallEvents
{
    // Not @synch'ed as should always be called inside @sync bloc
    if (![NSKeyedArchiver archiveRootObject:self.savedInstallEvents toFile:self.savedInstallEventsUrl.path]) {
        KMALog(@"KISSmetricsAPI - !WARNING! - Unable to archive savedInstallEvents!");
    }
}


- (void)kma_unarchiveSavedInstallEvents
{
    // Not @synch'ed as should always be called inside @sync bloc
    self.savedInstallEvents = [NSKeyedUnarchiver unarchiveObjectWithFile:self.savedInstallEventsUrl.path];
    if (!self.savedInstallEvents) {
        self.savedInstallEvents = [NSMutableArray array];
    }
}


- (void)kma_archiveSavedProperties
{
    // Not @synch'ed as should always be called inside @sync bloc
    if (![NSKeyedArchiver archiveRootObject:self.savedProperties toFile:self.savedPropertiesUrl.path]) {
        KMALog(@"KISSmetricsAPI - !WARNING! - Unable to archive savedProperties!");
    }
}


- (void)kma_unarchiveSavedProperties
{
    // Not @synch'ed as should always be called inside @sync bloc
    self.savedProperties = [NSKeyedUnarchiver unarchiveObjectWithFile:self.savedPropertiesUrl.path];
    if (!self.savedProperties) {
        self.savedProperties = [NSMutableDictionary dictionary];
    }
}


- (void)kma_archiveSendQueue
{
    // Not @synch'ed as should always be called inside @sync bloc
    if (![NSKeyedArchiver archiveRootObject:self.sendQueue toFile:self.actionsUrl.path]) {
        KMALog(@"KISSmetricsAPI - !WARNING! - Unable to archive data!");
    }
}


- (void)kma_unarchiveSendQueue
{
    // Not @synch'ed as should always be called inside @sync bloc
    self.sendQueue = [NSKeyedUnarchiver unarchiveObjectWithFile:self.actionsUrl.path];
    if (!self.sendQueue) {
        self.sendQueue = [NSMutableArray array];
    }
}



#pragma mark public keychain value getters/setters

- (void)setKeychainAppVersion:(NSString *)version
{
    @synchronized(self)
    {
        keychainAppVersion = version;
        KMAKeychainItemWrapper *keychainItem = [[KMAKeychainItemWrapper alloc] initWithIdentifier:kKMAKeychainAppVersionKey accessGroup:nil];
        [keychainItem setObject:keychainAppVersion forKey:(__bridge id)(kSecAttrGeneric)];
    }
}


- (NSString *)keychainAppVersion
{
    @synchronized(self)
    {
        // Populate the value from the keychain only if needed
        if (!keychainAppVersion) {
            KMAKeychainItemWrapper *keychainItem = [[KMAKeychainItemWrapper alloc] initWithIdentifier:kKMAKeychainAppVersionKey accessGroup:nil];
            keychainAppVersion = (NSString *)[keychainItem objectForKey:(__bridge id)(kSecAttrGeneric)];
        }
        return keychainAppVersion;
    }
}



#pragma mark - Private Unit Testing Helpers
// Use uth prefix for private test helpers

- (void)uth_truncateArchive
{
    KMALog(@"KMAArchiver truncateArchive");
    @synchronized(self)
    {
        [self.sendQueue removeAllObjects];
        KMALog(@"KMAArchive removeAllObjects");
        [self kma_archiveSendQueue];
    }
}

- (NSMutableArray *)uth_getSendQueue {
    return self.sendQueue;
}

- (NSMutableDictionary *)uth_getSettings {
    return self.settings;
}

- (NSMutableArray *)uth_getSavedIdEvents {
    return self.savedIdEvents;
}

- (NSMutableArray *)uth_getSavedInstallEvents {
    return self.savedInstallEvents;
}

- (NSMutableDictionary *)uth_getSavedProperties {
    return self.savedProperties;
}


@end
