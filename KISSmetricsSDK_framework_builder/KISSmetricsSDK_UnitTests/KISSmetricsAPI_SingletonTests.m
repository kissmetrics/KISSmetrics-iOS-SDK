//
// KISSmetricsSDK - Unit Tests
//
// KISSmetricsAPI_SingletonTests.m
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
#import "KISSmetricsAPI.h"

// Test support
#import <XCTest/XCTest.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>


@interface KISSmetricsAPI_SingletonTests : XCTestCase

- (void) runTestInSubprocess:(SEL)cmd;

@end


@implementation KISSmetricsAPI_SingletonTests
{
    // Test fixture ivars
    BOOL isInSubprocess;
}


- (void)setUp
{
    [super setUp];
    // Set-up
    
    // initialize with key otherwise all subsequent calls to [KISSmetricsAPI sharedAPI] will return nil
    [KISSmetricsAPI sharedAPIWithKey:@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"];
}


- (void)tearDown
{
    // Tear-down
    
    [super tearDown];
}

// set to false to run tests in foreground so you can see any exceptions thrown
#define doRunInSubprocess true


//We use this to ensure that no two test runs use the same instance.
- (void) runTestInSubprocess:(SEL)cmd
{
	pid_t pid = fork();
	if (pid == 0) {
		isInSubprocess = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:cmd];
#pragma clang diagnostic pop
		exit(0);
	} else {
		int status;
		waitpid(pid, &status, /*options*/ 0);
		if (WIFSIGNALED(status))
			raise(WTERMSIG(status));
		else if (WEXITSTATUS(status) != 0)
			exit(WEXITSTATUS(status));
	}
}



#pragma KISSmetricsAPI singleton tests

- (void) testSharedInstanceMethod
{
	if (!isInSubprocess && doRunInSubprocess)
    {
		[self runTestInSubprocess:_cmd];
		return;
	}
    
	KISSmetricsAPI *instance1 = [KISSmetricsAPI sharedAPI];
	XCTAssertNotNil(instance1, @"[KISSmetricsAPI sharedAPI] method (first time) returned nil!");
	KISSmetricsAPI *instance2 = [KISSmetricsAPI sharedAPI];
	XCTAssertNotNil(instance2, @"[KISSmetricsAPI sharedAPI] (second time) returned nil!");
	XCTAssertEqual(instance1, instance2, @"KISSmetricsAPI sharedAPI] method did not return the same object both times!");
}


- (void) testAllocInit
{
	if (!isInSubprocess && doRunInSubprocess) {
		[self runTestInSubprocess:_cmd];
		return;
	}
	
	KISSmetricsAPI *instance1 = [[KISSmetricsAPI alloc] init];
	XCTAssertNotNil(instance1, @"KISSmetricsAPI alloc/init/autorelease (first time) returned nil!");
	KISSmetricsAPI *instance2 = [[KISSmetricsAPI alloc] init];
	XCTAssertNotNil(instance2, @"KISSmetricsAPI alloc/init/autorelease (second time) returned nil!");
	XCTAssertEqual(instance1, instance2, @"KISSmetricsAPI alloc/init/autorelease did not return the same object both times!");
}


- (void) testOnlyOneInstance
{
	if (!isInSubprocess && doRunInSubprocess) {
		[self runTestInSubprocess:_cmd];
		return;
	}
	
	KISSmetricsAPI *instance1 = [[KISSmetricsAPI alloc] init];
	XCTAssertNotNil(instance1, @"KISSmetricsAPI alloc/init/autorelease returned nil!");
	KISSmetricsAPI *instance2 = [KISSmetricsAPI sharedAPI];
	XCTAssertNotNil(instance2, @"[KISSmetricsAPI sharedAPI] method returned nil!");
	XCTAssertEqual(instance1, instance2, @"Singleton method did not return the same object as alloc/init/autorelease!");
}


@end
