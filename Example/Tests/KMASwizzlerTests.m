//
// KISSmetricsSDK - Unit Tests
//
// KMASwizzlerTests.m
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


#import "KMASwizzledClass.h"

// Test support
#import <XCTest/XCTest.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>


@interface KMASwizzlerTests : XCTestCase
@end

@implementation KMASwizzlerTests
{
    // Test fixture ivars
}


- (void)setUp
{
    [super setUp];
    // Set-up
}


- (void)tearDown
{
    // Tear-down
    
    [super tearDown];
}


- (void)testSwizzledInstanceMethodIsCalledFirst
{
    ClassToBeSwizzled *swizzClass = [[ClassToBeSwizzled alloc] init];
    
    __block int callbackCount = 0;
    
    [swizzClass someInstanceMethodWithCompletion:^(NSString *string){
        callbackCount++;
        if(callbackCount ==1) {
            assertThat(string, equalTo(@"swizzled"));
        }
    }];
}


- (void)testOrigninalInstanceMethodIsCalledSecond
{
    ClassToBeSwizzled *swizzClass = [[ClassToBeSwizzled alloc] init];
    
    __block int callbackCount = 0;
    
    [swizzClass someInstanceMethodWithCompletion:^(NSString *string){
        callbackCount++;
        if(callbackCount ==2) {
            assertThat(string, equalTo(@"original"));
        }
    }];
}


- (void)testSwizzledClassMethodIsCalledFirst
{
    __block int callbackCount = 0;
    
    [ClassToBeSwizzled someClassMethodWithCompletion:^(NSString *string){
        callbackCount++;
        if(callbackCount ==1) {
            assertThat(string, equalTo(@"swizzled"));
        }
    }];
}


- (void)testOriginalClassMethodIsCalledSecond
{
    __block int callbackCount = 0;
    
    [ClassToBeSwizzled someClassMethodWithCompletion:^(NSString *string){
        callbackCount++;
        if(callbackCount ==2) {
            assertThat(string, equalTo(@"original"));
        }
    }];
}


@end


