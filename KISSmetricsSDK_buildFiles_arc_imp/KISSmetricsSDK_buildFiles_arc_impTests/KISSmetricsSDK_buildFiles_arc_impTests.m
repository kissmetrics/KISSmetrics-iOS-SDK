//
// KISSmetricsSDK_buildFiles_arc_impTests
//
// KISSmetricsSDK_buildFiles_arc_impTests.m
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



// System under test
#import "KISSmetricsAPI.h"
#import "KMAArchiver.h"
#import "KMAConnection.h"

// Test support
#import <XCTest/XCTest.h>
#import "NSNotificationCenter+AllObservers.h"
#import "MockNSURLConnection.h"
#import "TestableKMAConnection.h"

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>


@interface KISSmetricsAPI (privateClassMethods)
// Exposing the private class methods
+ (void)kma_setConnection:(KMAConnection *)connection;
@end


@interface KISSmetricsAPI (privateTestMethods)
// Exposing the private unit testing methods
+ (BOOL)uth_sharedAPIInitialized;
- (void)uth_testRequestSuccessful;
- (void)uth_testRequestReceivedError;
- (void)uth_testRequestReceivedUnexpectedStatusCode;
@end

@interface KMAArchiver (privateTestMethods)
// Exposing the private unit testing methods
- (void)uth_truncateArchive;
- (NSMutableArray *)uth_getSendQueue;
@end


@interface KISSmetricsAPI_buildFiles_arc_impTests : XCTestCase

@end

@implementation KISSmetricsAPI_buildFiles_arc_impTests
{
    int _urlSuccessCount;
    int _urlErrorCount;
    int _urlBadStatusCount;
}


- (void)setUp
{
    [super setUp];

    // Always start with a clean slate
    [[KMAArchiver sharedArchiver] uth_truncateArchive];
    
    _urlSuccessCount = 0;
    _urlErrorCount = 0;
    _urlBadStatusCount = 0;
}


- (void)tearDown
{
    // Clean up any saved events or properites between tests
    [[KMAArchiver sharedArchiver] uth_truncateArchive];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)_requestSuccessful
{
    _urlSuccessCount++;
}


- (void)_requestReceivedError
{
    _urlErrorCount++;
}


- (void)_requestReceivedUnexpectedStatusCode
{
    _urlBadStatusCount++;
}


// This is the only test that we run against the live server to ensure that our records are getting out.
- (void)testSuccessfulConnectionToKM
{
    [[KISSmetricsAPI sharedAPI] record:@"liveServerTest"];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Does not retain successfully uploaded records to the live server");
}


- (void)testSDKSelfInitialization
{
    XCTAssertTrue([KISSmetricsAPI uth_sharedAPIInitialized], @"KISSmetricsAPI sharedAPI initializes on load and will not be nil");
}


- (void)testDefaultIdentity
{
    XCTAssertNotNil([KISSmetricsAPI sharedAPI].identity, @"A default identity is set automatically");
}


- (void)testIdentifySetsIdentity
{
    NSString *newIdentity = @"KISSmetricsAPI@example.com";
    
    [MockNSURLConnection beginStubbing];
    
    [MockNSURLConnection stubEveryResponseStatus:200 body:@""];
    
    [[KISSmetricsAPI sharedAPI] identify:newIdentity];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    [MockNSURLConnection stopStubbing];
    
    XCTAssertTrue([newIdentity isEqualToString:[KISSmetricsAPI sharedAPI].identity], @"Identifying a user retains the set identity string");
}


- (void)testIdentityCannotBeNil
{
    NSString *lastIdentity = [KISSmetricsAPI sharedAPI].identity;
    NSString *newIdentity;
    
    [MockNSURLConnection beginStubbing];
    
    [MockNSURLConnection stubEveryResponseStatus:200 body:@""];
    
    [[KISSmetricsAPI sharedAPI] identify:newIdentity];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
    [MockNSURLConnection stopStubbing];
    
    
    XCTAssertTrue([lastIdentity isEqualToString:[KISSmetricsAPI sharedAPI].identity], @"Identifying a user as nil retains the last set identity string");
}


- (void)testIdentityCannotBeEmptyString
{
    NSString *lastIdentity = [KISSmetricsAPI sharedAPI].identity;
    NSString *newIdentity = @"";
    
    [MockNSURLConnection beginStubbing];
    
    [MockNSURLConnection stubEveryResponseStatus:200 body:@""];
    
    [[KISSmetricsAPI sharedAPI] identify:newIdentity];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
    [MockNSURLConnection stopStubbing];
    
    XCTAssertTrue([lastIdentity isEqualToString:[KISSmetricsAPI sharedAPI].identity], @"Identifying a user as an empty string retains the last set identity string");
}


- (void)testIdentityCannotBeResetToCurrentValue
{
    NSString *lastIdentity = [KISSmetricsAPI sharedAPI].identity;
    
    [MockNSURLConnection beginStubbing];
    
    // Mock KM service outage to ensure any created calls will end up in the queue
    [MockNSURLConnection stubEveryResponseStatus:503 body:@""];
    
    [[KISSmetricsAPI sharedAPI] identify:lastIdentity];

    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
    [MockNSURLConnection stopStubbing];
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Does not create and retain a new identity");
}


- (void)testAliasNotRetained
{
    NSString *identity = [KISSmetricsAPI sharedAPI].identity;
    NSString *alias = @"unitTestJhonny@example.com";
    
    
    [MockNSURLConnection beginStubbing];
    
    [MockNSURLConnection stubEveryResponseStatus:200 body:@""];
    
    [[KISSmetricsAPI sharedAPI] alias:alias withIdentity:identity];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
    [MockNSURLConnection stopStubbing];
    

    XCTAssertFalse([alias isEqualToString:[KISSmetricsAPI sharedAPI].identity], @"Aliasing an identity does not retain the alias as the identity");
}



- (void)testRemovesSuccessfulRecordsFromArchive
{
    // Ensure that we begin with an empty queue
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Begins with an emtpy archive");
    
    [MockNSURLConnection beginStubbing];

    [MockNSURLConnection stubEveryResponseStatus:200 body:@""];
    
    [[KISSmetricsAPI sharedAPI] record:@"passingURLResponseTest"];
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 5 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    [MockNSURLConnection stopStubbing];
    
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Removes successfully uploaded records fom the archives sendQueue");
}


- (void)testRemovesSuccessfulPropertiesFromArchive
{
    // Ensure that we begin with an empty queue
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Begins with an emtpy archive");
    
    [MockNSURLConnection beginStubbing];
    
    [MockNSURLConnection stubEveryResponseStatus:200 body:@""];
    
    [[KISSmetricsAPI sharedAPI] set:@{@"passingURLResonseTest": @YES}];
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 5 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    [MockNSURLConnection stopStubbing];
    
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Removes successfully uploaded properties fom the archives sendQueue");
}


- (void)testStressfulRecordsToKM
{
    // Ensure that we begin with an empty queue
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Begins with an emtpy archive");
    
    [MockNSURLConnection beginStubbing];
    
    [MockNSURLConnection stubEveryResponseStatus:200 body:@""];

    dispatch_async(dispatch_queue_create("com.kissmetrics.stress1", 0), ^{
        for (int i=0; i<100; i++) {
            NSString *record = [NSString stringWithFormat:@"passingURLResponseTestThread1_%i", i];
            [[KISSmetricsAPI sharedAPI] record:record];
        }
    });
    
    dispatch_async(dispatch_queue_create("com.kissmetrics.stress2", 0), ^{
        for (int i=0; i<100; i++) {
            NSString *record = [NSString stringWithFormat:@"passingURLResponseTestThread2_%i", i];\
            [[KISSmetricsAPI sharedAPI] record:record];
        }
    });
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 5 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    [MockNSURLConnection stopStubbing];

    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Removes successfully uploaded records fom the archives sendQueue");
}


- (void)testEmptyQueuePlacesSenderInReadyState
{
    // Ensure that we begin with an empty queue
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Begins with an emtpy archive");
    
    [MockNSURLConnection beginStubbing];
    
    [MockNSURLConnection stubEveryResponseStatus:200 body:@""];
    
    // Send 10 records
    for (int i=0; i<10; i++) {
        NSString *record = [NSString stringWithFormat:@"passingURLResponseTestSender1_%i", i];
        [[KISSmetricsAPI sharedAPI] record:record];
    }
    
    // Allow the queue to empty
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
    // Send another 10 records.
    // If Sender is not in the ready state, these will not be sent
    for (int i=0; i<10; i++) {
        NSString *record = [NSString stringWithFormat:@"passingURLResponseTestSender2_%i", i];
        [[KISSmetricsAPI sharedAPI] record:record];
    }
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 5 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
    [MockNSURLConnection stopStubbing];
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Removes successfully uploaded records fom the archives sendQueue");
}


- (void)testRemovesRecordsWithBadURLs
{
    int testRecordCount = 1;
    
    // Ensure that we begin our test with an empty queue
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Begins with an emtpy archive");
    
    
    [MockNSURLConnection beginStubbing];

    NSError *error = [[NSError alloc] initWithDomain:@"http://www.kissmetrics.com" code:NSURLErrorBadURL userInfo:nil];
    [MockNSURLConnection stubEveryResponseError:error];
    
    for (int i=0; i<testRecordCount; i++) {
        [[KISSmetricsAPI sharedAPI] record:@"testRemovesRecordsWithBadURLs"];
    }
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 5 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    [MockNSURLConnection stopStubbing];
    
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Removes records with bad URLs from the archived sendQueue");
}


- (void)testRetainsRecordsUnderServerOutage
{
    NSUInteger testRecordCount = 1;
    
    // Ensure that we begin our test with an empty queue
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Begins with an emtpy archive");
    
    [MockNSURLConnection beginStubbing];
    
    // Mock KM service outage
    [MockNSURLConnection stubEveryResponseStatus:503 body:@""];
    
    for (int i=0; i<testRecordCount; i++) {
        [[KISSmetricsAPI sharedAPI] record:@"testRetainsRecordsUnderServerOutage"];
    }
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 5 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    [MockNSURLConnection stopStubbing];
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], testRecordCount, @"Retains records in archive during KM server outage");
}


- (void)testRetainsPropertiesUnderServerOutage
{
    NSUInteger testRecordCount = 1;
    
    // Ensure that we begin our test with an empty queue
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Begins with an emtpy archive");
    
    [MockNSURLConnection beginStubbing];
    
    // Mock KM service outage
    [MockNSURLConnection stubEveryResponseStatus:503 body:@""];
    
    for (int i=0; i<testRecordCount; i++) {
        [[KISSmetricsAPI sharedAPI] set:@{@"testRetainsPropertiessUnderServerOutage": @YES}];
    }
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 5 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], testRecordCount, @"Retains records in archive during KM server outage");
    
    [MockNSURLConnection stopStubbing];
}


- (void)testStopsRecursiveSendOnFirstFailure
{
    NSUInteger testRecordCount = 1;
    
    // Ensure that we begin our test with an empty queue
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Begins with an emtpy archive");

    [MockNSURLConnection beginStubbing];
    
    // Mock KM service outage
    [MockNSURLConnection stubEveryResponseStatus:503 body:@""];
    
    for (int i=0; i<=testRecordCount; i++) {
        [[KISSmetricsAPI sharedAPI] record:@"testStopsRecursiveSendOnFirstFailure"];
    }
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 5 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    [MockNSURLConnection stopStubbing];
    
    // We should only see one bad status in return per record.
    // If we see more, our nsi_recursiveSend is not bailing on the send loop as it should.
    // Ideally we see fewer since we empty the _connectionOpQueue with cancelAllOperations and we do often see fewer,
    // but an equal number is acceptable.
    XCTAssertTrue(_urlBadStatusCount <= testRecordCount, @"Retains records in archive during KM server outage");
}


- (void)testTimeoutStopsRecursiveSendOnFirstFailure
 {
     NSUInteger testRecordCount = 2;
 
     // Ensure that we begin our test with an empty queue
     XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)0, @"Begins with an emtpy archive");
 
     [MockNSURLConnection beginStubbing];
 
     // Mock connection timeout or KM service outage via timeout
     NSError *error = [[NSError alloc] initWithDomain:@"http://www.kissmetrics.com" code:NSURLErrorTimedOut userInfo:nil];
     [MockNSURLConnection stubEveryResponseError:error];
 
     for (int i=0; i<=testRecordCount; i++) {
         [[KISSmetricsAPI sharedAPI] record:@"testTimeoutStopsRecursiveSendOnFirstFailure"];
     }
 
     [MockNSURLConnection stopStubbing];
 
     // We should only see one bad status in return per record.
     // If we see more, our nsi_recursiveSend is not bailing on the send loop as it should.
     // Ideally we see fewer since we empty the _connectionOpQueue with cancelAllOperations and we do often see fewer,
     // but an equal number is acceptable.
     XCTAssertTrue(_urlBadStatusCount <= testRecordCount, @"Retains records in archive during KM server outage");
 }

- (void)testSetDistinctStringProperty
{
    [MockNSURLConnection beginStubbing];
    
    // Mock KM service outage
    [MockNSURLConnection stubEveryResponseStatus:400 body:@""];
    
    // We have to start with a clear property record
    [[KMAArchiver sharedArchiver] clearSavedProperties];
    
    // This distinct property should be archived.
    [[KISSmetricsAPI sharedAPI] setDistinct:@"testValue" forKey:@"testSetDistinctStringProperty"];

    // This one should be dropped.
    [[KISSmetricsAPI sharedAPI] setDistinct:@"testValue" forKey:@"testSetDistinctStringProperty"];
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 2 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];

    // We should only see that one distinct property has been archived.
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)1, @"Retains only one string property during KM server outage");
    
    [MockNSURLConnection stopStubbing];
}


- (void)testSetDistinctNumberProperty
{
    [MockNSURLConnection beginStubbing];
    
    // Mock KM service outage
    [MockNSURLConnection stubEveryResponseStatus:400 body:@""];
    
    // We have to start with a clear property record
    [[KMAArchiver sharedArchiver] clearSavedProperties];
    
    // This distinct property should be archived.
    [[KISSmetricsAPI sharedAPI] setDistinct:[NSNumber numberWithInt:88] forKey:@"testSetDistinctNumberProperty"];
    
    NSLog(@"[[KMAArchiver sharedArchiver] getQueueCount] = %lul", (unsigned long)[[KMAArchiver sharedArchiver] getQueueCount]);
    
    // This one should be dropped.
    [[KISSmetricsAPI sharedAPI] setDistinct:[NSNumber numberWithInt:88] forKey:@"testSetDistinctNumberProperty"];
    
    NSLog(@"[[KMAArchiver sharedArchiver] getQueueCount] = %lul", (unsigned long)[[KMAArchiver sharedArchiver] getQueueCount]);
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 2 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
    
    NSLog(@"about to test");
    // We should only see that one distinct property has been archived.
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)1, @"Retains only one number property during KM server outage");
    
    [MockNSURLConnection stopStubbing];
}


// Test for connectivity change (connected) automatically fires nsi_recursiveSend in attempt to empty the queue


- (void)testDidRegisterForFinishedLaunchingNotification
{
    NSSet *observerSet = [[NSNotificationCenter defaultCenter] my_observersForNotificationName:UIApplicationDidFinishLaunchingNotification];
    
    BOOL found;
    for (id obj in observerSet){
        NSString *objClassName = [NSString stringWithFormat:@"%@",[obj class]];
        if([objClassName isEqualToString:@"KISSmetricsAPI"]){
            NSLog(@"containment");
            found = YES;
        }
    }
    
    XCTAssertTrue(found, @"KISSmetricsAPI auto-observes UIApplicationDidFinishLaunchingNotification");
}


- (void)testDidRegisterForEnterBackgroundNotification
{
    NSSet *observerSet = [[NSNotificationCenter defaultCenter] my_observersForNotificationName:UIApplicationDidEnterBackgroundNotification];
    
    BOOL found;
    for (id obj in observerSet){
        NSString *objClassName = [NSString stringWithFormat:@"%@",[obj class]];
        if([objClassName isEqualToString:@"KISSmetricsAPI"]){
            NSLog(@"containment");
            found = YES;
        }
    }
    
    XCTAssertTrue(found, @"KISSmetricsAPI auto-observes UIApplicationDidEnterBackgroundNotification");
}


- (void)testDidRegisterForBecomeActiveNotification
{
    NSSet *observerSet = [[NSNotificationCenter defaultCenter] my_observersForNotificationName:UIApplicationDidBecomeActiveNotification];
    
    BOOL found;
    for (id obj in observerSet){
        NSString *objClassName = [NSString stringWithFormat:@"%@",[obj class]];
        if([objClassName isEqualToString:@"KISSmetricsAPI"]){
            NSLog(@"containment");
            found = YES;
        }
    }
    
    XCTAssertTrue(found, @"KISSmetricsAPI auto-observes UIApplicationDidBecomeActiveNotification");
}


@end