//
// KISSmetricsSDK_buildFiles_arc_impTests
//
// KMAVCLifecycleTests.m
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



#import <XCTest/XCTest.h>

// Class under test
#import "AppDelegate.h" // <-- These are full application/integration tests
#import "ViewController.h"
#import "ViewControllerTwo.h"

#import "KISSmetricsAPI.h"
#import "KMAArchiver.h"
#import "KMAConnection.h"

#import "MockNSURLConnection.h"

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>


@interface KMAArchiver (privateTestMethods)
// Exposing the private unit testing methods
- (void)uth_truncateArchive;
@end

@interface KMAVCLifecycleTests : XCTestCase {
  AppDelegate *appDelegate;
  UINavigationController *navigationController;
  UIStoryboard *storyboard;

  ViewController *sut;
}

@end

@implementation KMAVCLifecycleTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    navigationController = (UINavigationController*)appDelegate.window.rootViewController;
    storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    sut  = [storyboard instantiateViewControllerWithIdentifier:@"viewController"];
    [sut performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    [sut view];
    
    // Always start with a clean slate
    [[KMAArchiver sharedArchiver] uth_truncateArchive];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    
    // Cleanup
    [[KMAArchiver sharedArchiver] uth_truncateArchive];
    
    [super tearDown];
}

/*
- (void)testSegueButtonConnected
{
    XCTAssertNotNil([sut segueButton], @"segueButton not connected");
}

- (void)testSegueButtonActionConnection
{
    UIButton *button = [sut segueButton];
    XCTAssertTrue([[button actionsForTarget:sut forControlEvent:UIControlEventTouchUpInside] containsObject:@"segueAction:"], @"segueAction not connected");
}

- (void)testSegueToViewControllerTwoConnected
{
    XCTAssertNoThrow([sut performSegueWithIdentifier:@"vc2Segue" sender:self], @"ExamplesVC should be connected");
}
*/

- (void)testManualSegueToViewControllerTwo
{
    // We should see that "ViewController viewDidDisappear"
    // and. "ViewController2 viewDidDisappear"
    
    [MockNSURLConnection beginStubbing];
    
    // Mock KM service outage
    [MockNSURLConnection stubEveryResponseStatus:503 body:@""];
    
    
    ViewControllerTwo *vc2 = [storyboard instantiateViewControllerWithIdentifier:@"viewControllerTwo"];
    [navigationController pushViewController:vc2 animated:YES];
    [vc2 view]; // We need to reference the view to ensure that it's loaded
    
    // The nsi_recursiveSend does not return or callback on completion.
    // We expect this opertion to complete within 5 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
    [MockNSURLConnection stopStubbing];
    
    
    
    XCTAssertEqualObjects(vc2.title, @"viewController2", @"vc2 Title mismatch");
    
    // There should be 2 records left in the queue. One for "ViewController viewDidDisappear" and one for "ViewController2 viewDidAppear"
    XCTAssertEqual([[KMAArchiver sharedArchiver] getQueueCount], (NSUInteger)2, @"Retains records in archive during KM server outage");
}


@end
