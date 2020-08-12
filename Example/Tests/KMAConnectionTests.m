//
// KISSmetricsSDK - Unit Tests
//
// KMAConnectionTests.m
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
#import "KMAConnection.h"

// Test support
#import <XCTest/XCTest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>


// Exposing KMAConnection private methods for testing
@interface KMAConnection (privateTestMethods)

// Unit test private helper methods
- (NSURLConnection *)uth_getConnection;
- (NSString *)uth_getUrlString;

@end



@interface KMAConnectionTests : XCTestCase
@end

@implementation KMAConnectionTests
{
    // Test fixture ivars
}

- (void)setUp
{
    [super setUp];

}

- (void)tearDown
{

    [super tearDown];
}


- (void)testSendRecordWithURLStringDoesNotModifyUrl
{
    KMAConnection *kmaConnection = [[KMAConnection alloc] init];
    
    NSString *testUrlString = @"http.www.google.com";
    
    NSURL *expectedURL = [NSURL URLWithString:testUrlString];
    
    [kmaConnection sendRecordWithURLString:testUrlString delegate:nil];
    
    NSURLConnection *connection = [kmaConnection uth_getConnection];
    NSURLRequest *request = connection.originalRequest;
    
    XCTAssertEqualObjects(request.URL, expectedURL, @"Does not modify the passed URL");
}


- (void)testSendRecordWithURLStringAllowsCellularConnection
{
    KMAConnection *kmaConnection = [[KMAConnection alloc] init];
    
    NSString *testUrlString = @"http.www.google.com";

    [kmaConnection sendRecordWithURLString:testUrlString delegate:nil];
    
    NSURLConnection *connection = [kmaConnection uth_getConnection];
    NSURLRequest *request = connection.originalRequest;
    
    XCTAssertTrue(request.allowsCellularAccess, @"Connections allow for cellular access");
}


- (void)testSendRecordWithURLStringAppliesCorrectTimeout
{
    KMAConnection *kmaConnection = [[KMAConnection alloc] init];
    
    NSString *testUrlString = @"http.www.google.com";

    [kmaConnection sendRecordWithURLString:testUrlString delegate:nil];
    
    NSURLConnection *connection = [kmaConnection uth_getConnection];
    NSURLRequest *request = connection.originalRequest;
    
    XCTAssertEqual(request.timeoutInterval, (NSTimeInterval)20, @"Connection apply a 20 second timeout");
}


- (void)testSendRecordWithURLStringAppliesCorrectCachePolicy
{
    KMAConnection *kmaConnection = [[KMAConnection alloc] init];
    
    NSString *testUrlString = @"http.www.google.com";
    
    [kmaConnection sendRecordWithURLString:testUrlString delegate:nil];
    
    NSURLConnection *connection = [kmaConnection uth_getConnection];
    NSURLRequest *request = connection.originalRequest;
    
    XCTAssertEqual((NSUInteger)request.cachePolicy, (NSUInteger)NSURLRequestUseProtocolCachePolicy, @"Uses NSURLRequestUseProtocolCachePolicy cache policy");
}


- (void)testSendRecordWithURLStringCreatesCorrectNSURLRequest
{
    KMAConnection *kmaConnection = [[KMAConnection alloc] init];
    
    NSString *testUrlString = @"http.www.google.com";
    
    NSURL *expectedURL = [NSURL URLWithString:testUrlString];
    
    [kmaConnection sendRecordWithURLString:testUrlString delegate:nil];
    
    NSURLConnection *connection = [kmaConnection uth_getConnection];
    NSURLRequest *request = connection.originalRequest;
    
    NSLog(@"request.timeoutInterval = %f", request.timeoutInterval);
    NSLog(@"request.url = %@", request.URL);
    NSLog(@"request.HTTPMethod = %@", request.HTTPMethod);
    NSLog(@"request.allowsCellularAccess = %i", request.allowsCellularAccess);
    
    XCTAssertTrue(request.allowsCellularAccess, @"Connections allow for cellular access");
    
    XCTAssertEqual(request.timeoutInterval, (NSTimeInterval)20, @"Connection apply a 20 second timeout");

    XCTAssertEqualObjects(request.URL, expectedURL, @"Does not modify the passed URL");
    
    XCTAssertEqualObjects(request.HTTPMethod, @"GET", @"Runs GET requests");
}

@end
