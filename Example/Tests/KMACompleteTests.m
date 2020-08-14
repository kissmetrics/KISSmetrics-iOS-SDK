//
//  KMACompleteTests.m
//  KISSmetricsSDK_framework_builder
//
//  Created by Peter O'Leary on 11/20/16.
//  Copyright © 2016 KISSmetrics. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KISSmetricsAPI.h"
#import "KISSmetricsSDK_UnitTests.h"

@interface KMACompleteTests : XCTestCase

@end

@implementation KMACompleteTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [KISSmetricsAPI sharedAPIWithKey:API_KEY];
    [[KISSmetricsAPI sharedAPI] forTesting];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRecordEvent {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [[KISSmetricsAPI sharedAPI] record:@"/app_launched"];
    [[KISSmetricsAPI sharedAPI] forTesting];
}

- (void)testRecordEventLarge {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [[KISSmetricsAPI sharedAPI] record:@"/app_launched" withProperties: LARGE_TEST_PROPERTIES];
    [[KISSmetricsAPI sharedAPI] forTesting];
}

@end
