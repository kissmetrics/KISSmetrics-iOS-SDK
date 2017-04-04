//
// KISSmetricsSDK - Unit Tests
//
// KMAArchiverTests.m
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



// Class under test
#import "KMAArchiver.h"

// Collaborators
#import "KMAKeychainItemWrapper.h"
#import "KMAQueryEncoder.h"

// Test support
#import <XCTest/XCTest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "KISSmetricsSDK_UnitTests.h"


// Exposing KMAArchiver private methods for testing
@interface KMAArchiver (privateTestMethods)

- (void)kma_unarchiveIdentity;

- (void)kma_unarchiveSavedIdEvents;
- (void)kma_archiveSavedIdEvents;

- (void)kma_unarchiveSavedInstallEvents;
- (void)kma_archiveSavedInstallEvents;

- (void)kma_unarchiveSavedProperties;
- (void)kma_archiveSavedProperties;

- (void)kma_unarchiveSendQueue;
- (void)kma_archiveSendQueue;

- (void)kma_unarchiveSettings;
- (void)kma_archiveSettings;

- (NSMutableDictionary *)_getSavedProperties;


// Unit test private helper methods
- (void)uth_truncateArchive;
- (NSMutableArray *)uth_getSendQueue;
- (NSMutableDictionary *)uth_getSettings;
- (NSMutableArray *)uth_getSavedIdEvents;
- (NSMutableArray *)uth_getSavedInstallEvents;
- (NSMutableDictionary *)uth_getSavedProperties;

@end



@interface KMAArchiverTests : XCTestCase
@end

@implementation KMAArchiverTests
{
    // Test fixture ivars go here
    KMAQueryEncoder *_queryEncoder;
    
    NSString *_reservedString;
    NSString *_encodedReservedString;
    NSString *_unsafeString;
    NSString *_encodedUnsafeString;
    NSString *_unreservedString;
    NSString *_encodedUnreservedString;
    
    NSString *_key;
    NSString *_clientType;
    NSString *_userAgent;
}


- (void)setUp
{
    [super setUp];
    
    NSLog(@"KMAArchiverTests setUp");
    
    _key = API_KEY;
    _clientType  = @"mobile_app";
    _userAgent   = @"kissmetrics-ios/2.3.1";
    
    [KMAArchiver sharedArchiverWithKey:_key];
    
    _queryEncoder = [[KMAQueryEncoder alloc] initWithKey:_key
                                              clientType:_clientType
                                               userAgent:_userAgent];
    //http://tools.ietf.org/html/rfc3986
    _reservedString = @"!*'();:@&=+$,/?#[]";
    _encodedReservedString = @"%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%23%5B%5D";
    _unsafeString = @"<>#%{}|\\^~` []";
    _encodedUnsafeString = @"%3C%3E%23%25%7B%7D%7C%5C%5E~%60%20%5B%5D";
    _unreservedString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
    _encodedUnreservedString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
    
    [self cleanSlate];
}


- (void)tearDown
{
    NSLog(@"KMAArchiverTests tearDown");
    
    [super tearDown];
}


- (NSURL *)kma_libraryUrlWithPathComponent:(NSString *)pathComponent
{
    NSURL *libraryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                                inDomains:NSUserDomainMask] lastObject];
    NSURL *componentURL = [libraryURL URLByAppendingPathComponent:pathComponent];
    return componentURL;
}


- (void)cleanSlate
{
    // Keep in mind:
    // 1. NSArchiver data will persist between tests.
    // 2. We're testing a singleton class that runs code in its init method.
    //    The init method is run before any test setup and because it's a singleton we cannot run init again.
    //    Running clean slate will remove all stored data and return KMAArchiver to a state of just after running
    //    init for the first time on a new device.
    
    NSString *librarySearchPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    
    // Empty the archive file at the identity path
    NSString *identityArchivePath = [librarySearchPath stringByAppendingPathComponent:@"KISSmetrics/identity.kma"];
    [NSKeyedArchiver archiveRootObject:nil toFile:identityArchivePath];
    [[KMAArchiver sharedArchiver] kma_unarchiveIdentity];
    
    NSString *actionsArchivePath = [librarySearchPath stringByAppendingPathComponent:@"KISSmetrics/actions.kma"];
    [NSKeyedArchiver archiveRootObject:nil toFile:actionsArchivePath];
    [[KMAArchiver sharedArchiver] kma_unarchiveSendQueue];

    NSString *settingsArchivePath = [librarySearchPath stringByAppendingPathComponent:@"KISSmetrics/settings.kma"];
    [NSKeyedArchiver archiveRootObject:nil toFile:settingsArchivePath];
    [[KMAArchiver sharedArchiver] kma_unarchiveSettings]; // Exposed private method
    
    // Empty the archive file at the savedIdEvents path (record once per ID events live here)
    NSString *savedIdEventsPath = [librarySearchPath stringByAppendingPathComponent:@"KISSmetrics/savedEvents.kma"];
    [NSKeyedArchiver archiveRootObject:nil toFile:savedIdEventsPath];
    [[KMAArchiver sharedArchiver] kma_unarchiveSavedIdEvents];
    
    // Empty the archive file at the savedInstallEvents path (record once per install events live here)
    NSString *savedInstallEventsPath = [librarySearchPath stringByAppendingPathComponent:@"KISSmetrics/savedInstallEvents.kma"];
    [NSKeyedArchiver archiveRootObject:nil toFile:savedInstallEventsPath];
    [[KMAArchiver sharedArchiver] kma_unarchiveSavedInstallEvents];
    
    // Empty the archive file at the savedProperties path (setDistinct properties live here)
    NSString *savedPropertiesPath = [librarySearchPath stringByAppendingPathComponent:@"KISSmetrics/savedProperties.kma"];
    [NSKeyedArchiver archiveRootObject:nil toFile:savedPropertiesPath];
    [[KMAArchiver sharedArchiver] kma_unarchiveSavedProperties];
}


- (void)testCleanSlateHelper
{
    [self cleanSlate];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getIdentity], nil, @"expects a nil archive");
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"expects a nil record");
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"expects 0 in queue count");
}


- (void)testArchiveInstallUuidRetainsUuidInSettings
{
    NSString *expectedUuid = @"91689fe0-77f6-11e3-981f-0800200c9a66";
    [[KMAArchiver sharedArchiver] archiveInstallUuid:expectedUuid];
    
    NSMutableDictionary *settings = [[KMAArchiver sharedArchiver] uth_getSettings];
    
    XCTAssertEqualObjects([settings objectForKey:@"installUuid"], expectedUuid, @"Install Uuid is retained in settings");
}


- (void)testArchiveDoTrackRetainsDoTrackInSettings
{
    NSNumber *expectedDoTrack = [NSNumber numberWithBool:NO];
    [[KMAArchiver sharedArchiver] archiveDoTrack:[expectedDoTrack boolValue]];
    
    NSMutableDictionary *settings = [[KMAArchiver sharedArchiver] uth_getSettings];
    
    XCTAssertEqualObjects([settings objectForKey:@"doTrack"], expectedDoTrack, @"doTrack is retained in settings");
}


- (void)testArchiveDoSendRetainsDoSendInSettings
{
    NSNumber *expectedDoSend = [NSNumber numberWithBool:NO];
    [[KMAArchiver sharedArchiver] archiveDoTrack:[expectedDoSend boolValue]];
    
    NSMutableDictionary *settings = [[KMAArchiver sharedArchiver] uth_getSettings];
    
    XCTAssertEqualObjects([settings objectForKey:@"doSend"], expectedDoSend, @"doSend is retained in settings");
}


- (void)testArchiveBaseUrlRetainsBaseUrlInSettings
{
    NSString *expectedBaseUrl = @"http://www.kissmetrics.com";
    [[KMAArchiver sharedArchiver] archiveBaseUrl:expectedBaseUrl];
    
    NSMutableDictionary *settings = [[KMAArchiver sharedArchiver] uth_getSettings];
    
    XCTAssertEqualObjects([settings objectForKey:@"baseUrl"], expectedBaseUrl, @"baseUrl is retained in settings");
}


- (void)testArchiveVerificationExpDateRetainsExpDate
{
    NSNumber *expectedVerficationExpDate = @(1389139547);
    [[KMAArchiver sharedArchiver] archiveVerificationExpDate:expectedVerficationExpDate];
    
    NSMutableDictionary *settings = [[KMAArchiver sharedArchiver] uth_getSettings];

    XCTAssertEqualObjects([settings objectForKey:@"verificationExpDate"], expectedVerficationExpDate, @"verificationExpDate is retained in settings");
}


- (void)testArchiveHasGenericIdentityRetainsHasGenericIdentityInSettings
{
    NSNumber *expectedHasGenericIdentity = [NSNumber numberWithBool:YES];
    [[KMAArchiver sharedArchiver] archiveHasGenericIdentity:[expectedHasGenericIdentity boolValue]];
    
    NSMutableDictionary *settings = [[KMAArchiver sharedArchiver] uth_getSettings];
    
    XCTAssertEqualObjects([settings objectForKey:@"hasGenericIdentity"], expectedHasGenericIdentity, @"hasGenericIdentity is retained in settings");
}


- (void)testArchiveFirstIdentitySetsIdentity
{
    NSString *testIdentity = @"MyTestIdentity";

    [[KMAArchiver sharedArchiver] archiveFirstIdentity:testIdentity];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getIdentity], testIdentity, @"Archive holds our test identity");
}


- (void)testArchiveFirstIdentityDoesNotCreateRecord
{
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:@"firstUser@example.com"];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"Returns Nil");
}


- (void)testArchiveFirstIdentityIgnoresNilValue
{
    NSString *testIdentity = @"FirstIdentity";
    
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:testIdentity];
    
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:nil];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getIdentity], testIdentity, @"Archive holds our test identity");
}


- (void)testArchiveFirstIdentityIgnoresEmptyValue
{
    NSString *testIdentity = @"FirstIdentity";
    
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:testIdentity];
    
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:@""];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getIdentity], testIdentity, @"Archive holds our test identity");
}


- (void)testGetQueryStringAtIndexReturnsRecord
{
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *expectedUrlString = [_queryEncoder createEventQueryWithName:@"testGetFirstRecordReturnsRecord"
                                                               properties:nil
                                                                 identity:@"testuser@example.com"
                                                                timestamp:timestamp];
    
    [[[KMAArchiver sharedArchiver] uth_getSendQueue] addObject:expectedUrlString];

    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], expectedUrlString, @"Returns Nil");
}


- (void)testGetFirstRecordReturnsNilFromEmptySendQueue
{
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"Returns Nil");
}


- (void)testRemoveFirstRecord
{
    int timestamp1 = [[NSDate date] timeIntervalSince1970];
    NSString *testRecord1 = [_queryEncoder createEventQueryWithName:@"firstRecord"
                                                         properties:nil
                                                           identity:@"testuser@example.com"
                                                          timestamp:timestamp1];
    
    [[[KMAArchiver sharedArchiver] uth_getSendQueue] addObject:testRecord1];
    
    int timestamp2 = [[NSDate date] timeIntervalSince1970];
    NSString *testRecord2 = [_queryEncoder createEventQueryWithName:@"secondRecord"
                                                         properties:nil
                                                           identity:@"testuser@example.com"
                                                          timestamp:timestamp2];
    
    [[[KMAArchiver sharedArchiver] uth_getSendQueue] addObject:testRecord2];
    
    // Now remove the first record
    [[KMAArchiver sharedArchiver] removeQueryStringAtIndex:0];
    
    // And we should be left with the 2nd record
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], testRecord2, @"Returns secondRecord");
}


- (void)testGetQueueCountForZero
{
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Returns 0");
}


- (void)testGetQueueCountForOne
{
    [[[KMAArchiver sharedArchiver] uth_getSendQueue] addObject:@"AnyTestObjectWorks"];
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)1, @"Returns 0");
}


- (void)testArchiveEventWithNilProperties
{
    NSString *userNameString = @"testuser@example.com";
    
    NSString *eventNameString = @"testArchiveRecord";
    
    // Only using this to set an expected identity
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:userNameString];

    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *expectedRecord = [_queryEncoder createEventQueryWithName:eventNameString properties:nil identity:userNameString timestamp:timestamp];
    
    // User archiveRecord to create a similar record. (timestamp may not match expected record)
    [[KMAArchiver sharedArchiver] archiveEvent:eventNameString withProperties:nil onCondition:KMARecordAlways];
    
    // !!!: The timestamp of archiveRecord and the expectedRecord may not match.
    // If this is a frequent result we should remove the &t=xxxxxxxxx from
    // both the archiveRecord and expectedRecord prior to comparison.
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], expectedRecord, @"Records do not match");
}


- (void)testArchiveEventWithProperties
{
    NSString *userNameString = @"testuser@example.com";
    
    NSString *eventNameString = @"testArchiveRecord";
    
    NSDictionary *propertiesDictionary = @{@"propertyOne" : @"testPropertyOne",
                                           @"propertyTwo" : @"testPropertyTwo"};
    
    // Only using this to set an expected identity
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:userNameString];
    
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *expectedRecord = [_queryEncoder createEventQueryWithName:eventNameString properties:propertiesDictionary identity:userNameString timestamp:timestamp];
    
    
    // User archiveRecord to create a similar record. (timestamp may not match expected record)
    [[KMAArchiver sharedArchiver] archiveEvent:eventNameString withProperties:propertiesDictionary onCondition:KMARecordAlways];
    
    // !!!: The timestamp of archiveRecord and the expectedRecord may not match.
    // If this is a frequent result we should remove the &t=xxxxxxxxx from
    // both the archiveRecord and expectedRecord prior to comparison.
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], expectedRecord, @"Records do not match");
}

- (void)testArchiveEventWithLargeProperties
{
    NSString *userNameString = @"testuser@example.com";
    
    NSString *eventNameString = @"testArchiveRecord";
    
    NSDictionary *propertiesDictionary = LARGE_TEST_PROPERTIES;
    
    // Only using this to set an expected identity
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:userNameString];
    
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *expectedRecord = [_queryEncoder createEventQueryWithName:eventNameString properties:propertiesDictionary identity:userNameString timestamp:timestamp];
    
    
    // User archiveRecord to create a similar record. (timestamp may not match expected record)
    [[KMAArchiver sharedArchiver] archiveEvent:eventNameString withProperties:propertiesDictionary onCondition:KMARecordAlways];
    
    // !!!: The timestamp of archiveRecord and the expectedRecord may not match.
    // If this is a frequent result we should remove the &t=xxxxxxxxx from
    // both the archiveRecord and expectedRecord prior to comparison.
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], expectedRecord, @"Records do not match");
}


- (void)testArchiveEventIgnoresNil
{
    [[KMAArchiver sharedArchiver] archiveEvent:nil withProperties:nil onCondition:KMARecordAlways];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"Records are nil");
}


- (void)testArchiveEventIgnoresEmptyString
{
    [[KMAArchiver sharedArchiver] archiveEvent:@"" withProperties:nil onCondition:KMARecordAlways];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"Records are nil");
}


- (void)testArchiveProperties
{
    NSString *userNameString = @"testuser@example.com";
    
    NSDictionary *propertiesDictionary = @{@"propertyOne" : @"testPropertyOne",
                                           @"propertyTwo" : @"testPropertyTwo"};
    
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:userNameString];

    int timestamp = [[NSDate date] timeIntervalSince1970];
    
    NSString *expectedRecord = [_queryEncoder createPropertiesQueryWithProperties:propertiesDictionary identity:userNameString timestamp:timestamp];
    
    // User archiveRecord to create a similar record. (timestamp may not match expected record)
    [[KMAArchiver sharedArchiver] archiveProperties:propertiesDictionary];
    
    // !!!: The timestamp of archiveProperties and the expectedRecord may not match.
    // If this is a frequent result we should remove the &t=xxxxxxxxx from
    // both the archiveProperties and expectedRecord prior to comparison.
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], expectedRecord, @"Records do not match");
}


- (void)testArchivePropertiesIgnoresNilProperties
{
    [[KMAArchiver sharedArchiver] archiveProperties:nil];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"Record are nil");
}


- (void)testArchivePropertiesIgnoresEmptyProperties
{
    [[KMAArchiver sharedArchiver] archiveProperties:@{}];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"Record are nil");
}


- (void)testArchiveIdentityRetainsLastIdentity
{
    NSString *expectedIdentity = @"retainedIdentity@example.com";
    
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:expectedIdentity];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getIdentity], expectedIdentity, @"Archived identities are retained and returned via getIdentity");
}


- (void)testArchiveIdentityCreatesAliasQueryWhenLastIdentityWasGeneric
{
    NSLog(@"[[KMAArchiver sharedArchiver] hasGenericIdentity] = %i", [[KMAArchiver sharedArchiver] hasGenericIdentity]);

    // Only using this to set an expected identity
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:@"oldTestUser@example.com"];
    
    NSLog(@"[[KMAArchiver sharedArchiver] hasGenericIdentity] = %i", [[KMAArchiver sharedArchiver] hasGenericIdentity]);

    NSString *identityString = @"testNewUser@example.com";
     
    NSString *expectedRecord = [_queryEncoder createAliasQueryWithAlias:identityString andIdentity:[[KMAArchiver sharedArchiver] getIdentity]];
    
    [[KMAArchiver sharedArchiver] archiveIdentity:identityString];
    
    // !!!: The timestamp of archiveProperties and the expectedRecord may not match.
    // If this is a frequent result we should remove the &t=xxxxxxxxx from
    // both the archiveIdentity and expectedRecord prior to comparison.
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], expectedRecord, @"An alias query is created for the archive identity");
}


- (void)testArchiveIdentityDoesNotCreateAliasQueryWhenLastIdentityWasNotGeneric
{
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:@"someUnknownGenericIdentity"];
    
    [[KMAArchiver sharedArchiver] archiveHasGenericIdentity:NO];
    
    [[KMAArchiver sharedArchiver] archiveIdentity:@"someKnownIdentity@example.com"];
    
    NSArray *sendQueue = [[KMAArchiver sharedArchiver] uth_getSendQueue];
    XCTAssertEqual([sendQueue count] , (NSUInteger)0, @"No query is created for the archived identity");
}


- (void)testArchiveIdentityClearsSavedIdEventsWhenLastIdentityWasNotGeneric
{
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:@"someUnknownGenericIdentity"];
    [[KMAArchiver sharedArchiver] archiveIdentity:@"someKnownIdentity@example.com"];
    
    // Populate and directly archive the test events
    NSMutableArray *testEvents = (NSMutableArray*)@[@"testEvent"];
    NSString *savedIdEventsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/savedEvents.kma"];
    [NSKeyedArchiver archiveRootObject:testEvents toFile:savedIdEventsPath];
    [[KMAArchiver sharedArchiver] kma_unarchiveSavedIdEvents];
    
    
    [[KMAArchiver sharedArchiver] archiveIdentity:@"aDifferentUser@example.com"];
    
    XCTAssertEqual([[[KMAArchiver sharedArchiver] uth_getSavedIdEvents] count] , (NSUInteger)0, @"Saved ID events are cleared when archiving an identity when the last identity was not generic");
}


- (void)testArchiveIdentityClearsSavedPropertiesWhenLastIdentityWasNotGeneric
{
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:@"someUnknownGenericIdentity"];
    [[KMAArchiver sharedArchiver] archiveIdentity:@"someKnownIdentity@example.com"];
    
    // Populate and directly archive the test properties
    NSMutableDictionary *testProperties = (NSMutableDictionary*)@{@"testProperty": @"testPropertyValue"};
    NSString *savedPropertiesPath =[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/savedProperties.kma"];
    [NSKeyedArchiver archiveRootObject:testProperties toFile:savedPropertiesPath];
    [[KMAArchiver sharedArchiver] kma_unarchiveSavedProperties];
    
    [[KMAArchiver sharedArchiver] archiveIdentity:@"aDifferentUser@example.com"];
    
    XCTAssertEqual([[[KMAArchiver sharedArchiver] uth_getSavedIdEvents] count] , (NSUInteger)0, @"Saved events are cleared when archiving an identity when the last identity was not generic");
}


- (void)testArchiveIdentityIgnoresNilIdentity
{
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:@"oldTestUser@example.com"];

    [[KMAArchiver sharedArchiver] archiveIdentity:nil];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"Record is nil");
}


- (void)testArchiveIdentityIgnoresEmptyIdentity
{
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:@"oldTestUser@example.com"];
    
    [[KMAArchiver sharedArchiver] archiveIdentity:@""];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"Record is nil");
}


- (void)testArchiveAlias
{
    NSString *identityString = @"testUser@example.com";
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:identityString];

    NSString *aliasString = @"testAlias@example.com";
    
    NSString *expectedRecord = [_queryEncoder createAliasQueryWithAlias:aliasString andIdentity:identityString];
    
    [[KMAArchiver sharedArchiver] archiveAlias:aliasString withIdentity:identityString];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], expectedRecord, @"Record matches expected alias record");
}


- (void)testArchiveAliasIgnoresNilStrings
{
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:@"testUser@example.com"];
    
    [[KMAArchiver sharedArchiver] archiveAlias:nil withIdentity:nil];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"Record is nil");
}


- (void)testArchiveAliasIgnoresEmptyStrings
{
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:@"testUser@example.com"];
    
    [[KMAArchiver sharedArchiver] archiveAlias:@"" withIdentity:@""];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], nil, @"Record is nil");
}


- (void)testArchiveEventOncePerId
{
    NSString *userNameString = @"testuser@example.com";
    
    NSString *eventNameString = @"uniqueIdEvent";
    
    // Only using this to set an expected identity
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:userNameString];
    
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *expectedRecord = [_queryEncoder createEventQueryWithName:eventNameString properties:nil identity:userNameString timestamp:timestamp];
    
    // User archiveRecord to create a similar record. (timestamp may not match expected record)
    [[KMAArchiver sharedArchiver] archiveEvent:eventNameString withProperties:nil onCondition:KMARecordOncePerIdentity];
    
    // !!!: The timestamp of the archived event and the expectedRecord may not match.
    // If this is a frequent result we should remove the &t=xxxxxxxxx from
    // both the archiveRecord and expectedRecord prior to comparison.
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], expectedRecord, @"Records do not match");
}


- (void)testArchiveEventOncePerIdIgnoresSubsequentCalls
{
    NSString *eventNameString = @"uniqueIdEvent";
    
    [[KMAArchiver sharedArchiver] archiveEvent:eventNameString withProperties:nil onCondition:KMARecordOncePerIdentity];

    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)1, @"Records only the first call to record");
}


- (void)testArchiveEventOncePerInstall
{
    NSString *userNameString = @"testuser@example.com";
    
    NSString *eventNameString = @"uniqueInstallEvent";
    
    // Only using this to set an expected identity
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:userNameString];
    
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *expectedRecord = [_queryEncoder createEventQueryWithName:eventNameString properties:nil identity:userNameString timestamp:timestamp];
    
    // User archiveRecord to create a similar record. (timestamp may not match expected record)
    [[KMAArchiver sharedArchiver] archiveEvent:eventNameString withProperties:nil onCondition:KMARecordOncePerInstall];
    
    // !!!: The timestamp of the archived event and the expectedRecord may not match.
    // If this is a frequent result we should remove the &t=xxxxxxxxx from
    // both the archiveRecord and expectedRecord prior to comparison.
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], expectedRecord, @"Records do not match");
}


- (void)testArchiveEventOncePerInstallIgnoresSubsequentCalls
{
    NSString *eventNameString = @"uniqueInstallEvent";
    
    [[KMAArchiver sharedArchiver] archiveEvent:eventNameString withProperties:nil onCondition:KMARecordOncePerInstall];
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)1, @"Records only the first call to record");
}


- (void)testArchiveDistinctPropertyValue
{
    NSString *userNameString = @"testuser@example.com";

    // Only using this to set an expected identity
    [[KMAArchiver sharedArchiver] archiveFirstIdentity:userNameString];
    
    int timestamp = [[NSDate date] timeIntervalSince1970];
    
    NSString *expectedRecord = [_queryEncoder createPropertiesQueryWithProperties:@{@"distinctProperty" : @"testDistinctValue"}
                                                                         identity:userNameString
                                                                        timestamp:timestamp];
    
    // User archiveRecord to create a similar record. (timestamp may not match expected record)
    [[KMAArchiver sharedArchiver] archiveDistinctProperty:@"distinctProperty" value:@"testDistinctValue"];
    
    // !!!: The timestamp of archiveDistinctProperty:value: and the expectedRecord may not match.
    // If this is a frequent result we should remove the &t=xxxxxxxxx from
    // both the archiveDistinctProperty and expectedRecord prior to comparison.
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getQueryStringAtIndex:0], expectedRecord, @"Records do not match");
}


- (void)testArchiveDistinctPropertyAcceptsNewValues
{
    // User archiveRecord to create a similar record. (timestamp may not match expected record)
    [[KMAArchiver sharedArchiver] archiveDistinctProperty:@"distinctProperty" value:@"testDistinctValue"];
    
    [[KMAArchiver sharedArchiver] archiveDistinctProperty:@"distinctProperty" value:@"testNewDistinctValue"];
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)2, @"2 Records exist");
}


- (void)testArchiveDistinctPropertyIgnoresOldValue
{
    // User archiveRecord to create a similar record. (timestamp may not match expected record)
    [[KMAArchiver sharedArchiver] archiveDistinctProperty:@"distinctProperty" value:@"testDistinctValue"];
    
    [[KMAArchiver sharedArchiver] archiveDistinctProperty:@"distinctProperty" value:@"testDistinctValue"];
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)1, @"1 Record exist");
}


- (void)testArchiveDistinctPropertyAllowsValueToggling
{
    [[KMAArchiver sharedArchiver] archiveDistinctProperty:@"distinctProperty" value:@"testDistinctValue"];
    
    [[KMAArchiver sharedArchiver] archiveDistinctProperty:@"distinctProperty" value:@"testNewDistinctValue"];
    
    [[KMAArchiver sharedArchiver] archiveDistinctProperty:@"distinctProperty" value:@"testDistinctValue"];

    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)3, @"3 Records exist");
}


- (void)testUnarchiveIdentitySetsLastIdentity
{
    NSString *identityString = @"testIdentity";
    
    [[KMAArchiver sharedArchiver] archiveIdentity:identityString];
    
    // unarchiveIdentity sets lastIdentity on KMAArchiver
    [[KMAArchiver sharedArchiver] kma_unarchiveIdentity];
    
    // getIdentity returns the value of lastIdentity on KMAArchive
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] getIdentity], identityString, @"Archived identity is returned by getIdentity");
}


- (void)testArchiveSavedIdEvents
{
    NSMutableArray *testIdEvents = [[KMAArchiver sharedArchiver] uth_getSavedIdEvents];
  
    [testIdEvents addObject:@"testIdEvent"];
    
    [[KMAArchiver sharedArchiver] kma_archiveSavedIdEvents];

    // Directly unarchive the events
    NSString *savedIdEventsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/savedEvents.kma"];
    NSArray *archivedIdEvents = [NSKeyedUnarchiver unarchiveObjectWithFile:savedIdEventsPath];

    XCTAssertEqualObjects(archivedIdEvents, testIdEvents, @"Archived ID event array returns unarchived array");
}


- (void)testUnarchiveSavedIdEvents
{
    // Populate and directly archive the test events
    NSMutableArray *testIdEvents = (NSMutableArray*)@[@"testIdEvent"];
    NSString *savedIdEventsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/savedEvents.kma"];
    [NSKeyedArchiver archiveRootObject:testIdEvents toFile:savedIdEventsPath];
    
    [[KMAArchiver sharedArchiver] kma_unarchiveSavedIdEvents];
    NSMutableArray *archivedIdEvents = [[KMAArchiver sharedArchiver] uth_getSavedIdEvents];

    XCTAssertEqualObjects(archivedIdEvents, testIdEvents, @"Unarchived ID event array returns archived array");
}


- (void)testClearSavedIdEvents
{
    // Populate and directly archive the test events
    NSMutableArray *testIdEvents = (NSMutableArray*)@[@"testIdEvent"];
    NSString *savedIdEventsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/savedEvents.kma"];
    [NSKeyedArchiver archiveRootObject:testIdEvents toFile:savedIdEventsPath];
    
    [[KMAArchiver sharedArchiver] kma_unarchiveSavedIdEvents];
    
    [[KMAArchiver sharedArchiver] clearSavedIdEvents];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] uth_getSavedIdEvents], [NSMutableArray array], @"Returns an emtpy mutable array");
}


- (void)testArchiveSavedInstallEvents
{
    NSMutableArray *testInstallEvents = [[KMAArchiver sharedArchiver] uth_getSavedInstallEvents];
    
    [testInstallEvents addObject:@"testInstallEvent"];
    
    [[KMAArchiver sharedArchiver] kma_archiveSavedInstallEvents];
    
    // Directly unarchive the events
    NSString *savedInstallEventsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/savedInstallEvents.kma"];
    NSArray *archivedInstallEvents = [NSKeyedUnarchiver unarchiveObjectWithFile:savedInstallEventsPath];
    
    XCTAssertEqualObjects(archivedInstallEvents, testInstallEvents, @"Archived install event array returns unarchived array");
}


- (void)testUnarchiveSavedInstallEvents
{
    // Populate and directly archive the test events
    NSMutableArray *testInstallEvents = (NSMutableArray*)@[@"testInstallEvent"];
    NSString *savedInstallEventsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/savedInstallEvents.kma"];
    [NSKeyedArchiver archiveRootObject:testInstallEvents toFile:savedInstallEventsPath];
    
    [[KMAArchiver sharedArchiver] kma_unarchiveSavedInstallEvents];
    NSMutableArray *archivedInstallEvents = [[KMAArchiver sharedArchiver] uth_getSavedInstallEvents];
    
    XCTAssertEqualObjects(archivedInstallEvents, testInstallEvents, @"Unarchived install event array returns archived array");
}


- (void)testArchiveSavedProperties
{
    NSMutableDictionary *testProperties = [[KMAArchiver sharedArchiver] uth_getSavedProperties];
    [testProperties addEntriesFromDictionary:@{@"testProperty": @"testPropertyValue"}];
    [[KMAArchiver sharedArchiver] kma_archiveSavedProperties];
    
    // Directly unarchive the properties
    NSString *savedPropertiesPath =[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/savedProperties.kma"];
    NSDictionary *archivedProperties = [NSKeyedUnarchiver unarchiveObjectWithFile:savedPropertiesPath];

    XCTAssertEqualObjects(archivedProperties, testProperties, @"Archived property dictionary returns unarchived dictionary");
}


- (void)testUnarchiveSavedProperties
{
    // Populate and directly archive the test properties
    NSMutableDictionary *testProperties = (NSMutableDictionary*)@{@"testProperty": @"testPropertyValue"};
    
    NSString *savedPropertiesPath =[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/savedProperties.kma"];
    [NSKeyedArchiver archiveRootObject:testProperties toFile:savedPropertiesPath];
    
    // Unarchive _savedProperties
    [[KMAArchiver sharedArchiver] kma_unarchiveSavedProperties];
    NSMutableDictionary *archivedProperties = [[KMAArchiver sharedArchiver] uth_getSavedProperties];

    XCTAssertEqualObjects(archivedProperties, testProperties, @"Unarchived property dictionary returns archived dictionary");
}


- (void)testClearSavedProperties
{
    // Populate and directly archive the test properties
    NSMutableDictionary *testProperties = (NSMutableDictionary*)@{@"testProperty": @"testPropertyValue"};
    
    NSString *savedPropertiesPath =[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/savedProperties.kma"];
    [NSKeyedArchiver archiveRootObject:testProperties toFile:savedPropertiesPath];
    
    [[KMAArchiver sharedArchiver] kma_unarchiveSavedProperties];
    
    [[KMAArchiver sharedArchiver] clearSavedProperties];
    
    XCTAssertEqualObjects([[KMAArchiver sharedArchiver] uth_getSavedProperties], [NSMutableDictionary dictionary], @"Returns an emtpy mutable dictionary");
}


- (void)testArchiveData
{
    NSMutableArray *sendQueue = [[KMAArchiver sharedArchiver] uth_getSendQueue];
    
    [sendQueue addObject:@"https://trk.kissmetrics.com/a?_k=b8f68fe5004d29bcd21d3138b43ae755a16c12cf&_x=ios/2.3.1&_p=testnewuser%40example.com&_n=testolduser%40example.com"];
    
    NSLog(@"sendQueue = %@", sendQueue);
    
    [[KMAArchiver sharedArchiver] kma_archiveSendQueue];
    
    // Directly unarchive the send queue
    NSString *sendQueuePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/actions.kma"];
    NSMutableArray *archivedSendQueue = [NSKeyedUnarchiver unarchiveObjectWithFile:sendQueuePath];
    
    XCTAssertEqualObjects(archivedSendQueue, sendQueue, @"Archived sendQueue array returns unarchived array");
}


- (void)testUnarchiveData
{
    // Populate and directly archive the _sendQueue
    NSMutableArray *sendQueue = (NSMutableArray*)@[@"testEvent"];
    NSString *sendQueuePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KISSmetrics/actions.kma"];
    [NSKeyedArchiver archiveRootObject:sendQueue  toFile:sendQueuePath];
    
    [[KMAArchiver sharedArchiver] kma_unarchiveSendQueue];
    NSMutableArray *archivedSendQueue = [[KMAArchiver sharedArchiver] uth_getSendQueue];
    
    XCTAssertEqualObjects(archivedSendQueue, sendQueue, @"Unarchived sendQueue array returns archived array");
}



#pragma mark - keychain tests


- (void)testAppVersionKeychainSetter
{
    KMAKeychainItemWrapper *keychainItem = [[KMAKeychainItemWrapper alloc] initWithIdentifier:@"KMAAppVersion" accessGroup:nil];
    [keychainItem resetKeychainItem];
    
    // Set an app version string using the setter method
    NSString *appVersionString = @"1.2.3";
    [KMAArchiver sharedArchiver].keychainAppVersion = appVersionString;
    
    // Get the app version string directly
    NSString *resultVersionString = (NSString *)[keychainItem objectForKey:(__bridge id)kSecAttrGeneric];

    XCTAssertEqualObjects(resultVersionString, appVersionString, @"Stored keychain value matches");
}


- (void)testAppVersionKeychainGetter
{
    KMAKeychainItemWrapper *keychainItem = [[KMAKeychainItemWrapper alloc] initWithIdentifier:@"KMAAppVersion" accessGroup:nil];
    
    // Set an app version string directly
    NSString *appVersionString = @"1.2.3";
    [keychainItem setObject:appVersionString forKey:(__bridge id)kSecAttrGeneric];
    
    // Get the app version string using the getter method
    NSString *resultVersionString = [KMAArchiver sharedArchiver].keychainAppVersion;
    
    XCTAssertEqualObjects(resultVersionString, appVersionString, @"Stored keychain value matches");
}


@end
