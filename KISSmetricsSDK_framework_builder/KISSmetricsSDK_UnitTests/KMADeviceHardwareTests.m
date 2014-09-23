//
// KISSmetricsSDK - Unit Tests
//
// KMADeviceHardwareTests.m
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
#import "UIDevice+KMAHardware.h"

// Test support
#import <XCTest/XCTest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>


@interface KMADeviceHardwareTests : XCTestCase
@end

@implementation KMADeviceHardwareTests
{
    // Test fixture ivars
}

// Logic unit tests cannot be run on iOS devices

- (void)testkmac_platformReturnsPlatfromString
{
    NSArray *expectedPlatforms = @[@"iFPGA",
                                   @"iPhone1,1", @"iPhone1,2", @"iPhone 3G", @"iPhone2,1", @"iPhone3,1", @"iPhone3,2", @"iPhone3,3", @"iPhone4,1", @"iPhone5,1", @"iPhone5,2", @"iPhone5,3", @"iPhone5,4", @"iPhone6,1", @"iPhone6,2", @"iPhone7,1", @"iPhone7,2",
                                   @"iPod1,1", @"iPod2,1", @"iPod2,2", @"iPod3,1", @"iPod4,1",
                                   @"ipad0,1", @"iPad3,2", @"iPad3,3", @"iPad4,1", @"iPad4,2", @"iPad4,3",
                                   @"iProd2,1",
                                   @"AppleTV2,1",
                                   @"i386", @"x86_64"];
    
    // This value will vary based on simulator and device.
    // Ensure that the string matches one of the expected strings.
    NSString *platform = [[UIDevice currentDevice] kmac_platform];
    
    XCTAssertTrue([expectedPlatforms containsObject:platform], @"Expected test platfrom to be one of expected platforms but was not");
    // If this test is failing and you're running tests on a new device make sure this new device has been added to the KMA_UIDevicePlatform enum in UIDevice+KMAHarware.h AND expectedPlatforms array before you rip your hair out.
}


- (void)testkmac_platformTypeForString_iFPGA
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iFPGA"] == KMA_UIDeviceIFPGA), @"Expected iFPGA to return KMA_UIDeviceIFPGA");
}

- (void)testkmac_platformTypeForString_iPhone1_1
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone1,1"] == KMA_UIDeviceiPhone1), @"Expected iPhone1,1 to return KMA_UIDeviceiPhone1");
}

- (void)testkmac_platformTypeForString_iPhone1_2
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone1,2"] == KMA_UIDeviceiPhone3G), @"Expected iPhone1,2 to return KMA_UIDeviceiPhone3G");
}

- (void)testkmac_platformTypeForString_iPhone2
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone2,1"] == KMA_UIDeviceiPhone3GS), @"Expected iPhone2,1 to return KMA_UIDeviceiPhone3GS");
}

- (void)testkmac_platformTypeForString_iPhone3_1
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone3,1"] == KMA_UIDeviceiPhone4GSM), @"Expected iPhone3,1 to return KMA_UIDeviceiPhone4GSM");
}

- (void)testkmac_platformTypeForString_iPhone3_2
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone3,2"] == KMA_UIDeviceiPhone4GSMRevA), @"Expected iPhone3,2 to return KMA_UIDeviceiPhone4GSMRevA");
}

- (void)testkmac_platformTypeForString_iPhone3_3
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone3,3"] == KMA_UIDeviceiPhone4CDMA), @"Expected iPhone3,3 to return KMA_UIDeviceiPhone4CDMA");
}

- (void)testkmac_platformTypeForString_iPhone4
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone4,1"] == KMA_UIDeviceiPhone4S), @"Expected iPhone4,1 to return KMA_UIDeviceiPhone4S");
}

- (void)testkmac_platformTypeForString_iPhone5_1
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone5,1"] == KMA_UIDeviceiPhone5GSM), @"Expected iPhone5,1 to return KMA_UIDeviceiPhone5GSM");
}

- (void)testkmac_platformTypeForString_iPhone5_2
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone5,2"] == KMA_UIDeviceiPhone5GSMCDMA), @"Expected iPhone5,2 to return KMA_UIDeviceiPhone5GSMCDMA");
}

- (void)testkmac_platformTypeForString_iPhone5_3
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone5,3"] == KMA_UIDeviceiPhone5CGSM), @"Expected iPhone5,3 to return KMA_UIDeviceiPhone5CGSM");
}

- (void)testkmac_platformTypeForString_iPhone5_4
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone5,4"] == KMA_UIDeviceiPhone5CGSMCDMA), @"Expected iPhone5,4 to return KMA_UIDeviceiPhone5CGSMCDMA");
}

- (void)testkmac_platformTypeForString_iPhone6_1
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone6,1"] == KMA_UIDeviceiPhone5SGSM), @"Expected iPhone6,1 to return KMA_UIDeviceiPhone5SGSM");
}

- (void)testkmac_platformTypeForString_iPhone6_2
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone6,2"] == KMA_UIDeviceiPhone5SGSMCDMA), @"Expected iPhone6,2 to return KMA_UIDeviceiPhone5SGSMCDMA");
}

- (void)testkmac_platformTypeForString_iPhone7_1
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone7,1"] == KMA_UIDeviceiPhone6Plus), @"Expected iPhone7,1 to return KMA_UIDeviceiPhone6Plus");
}

- (void)testkmac_platformTypeForString_iPhone7_2
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone7,2"] == KMA_UIDeviceiPhone6), @"Expected iPhone7,2 to return KMA_UIDeviceiPhone6");
}

- (void)testkmac_platformTypeForString_iPod1
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPod1,1"] == KMA_UIDeviceiPodTouch1), @"Expected iPod1,1 to return KMA_UIDeviceiPodTouch1");
}

- (void)testkmac_platformTypeForString_iPod2
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPod2,1"] == KMA_UIDeviceiPodTouch2), @"Expected iPod2,1 to return KMA_UIDeviceiPodTouch2");
}

- (void)testkmac_platformTypeForString_iPod2_2
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPod2,2"] == KMA_UIDeviceiPodTouch3), @"Expected iPod2,2 to return KMA_UIDeviceiPodTouch3");
}

- (void)testkmac_platformTypeForString_iPod3
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPod3,1"] == KMA_UIDeviceiPodTouch3), @"Expected iPod3,1 to return KMA_UIDeviceiPodTouch3");
}

- (void)testkmac_platformTypeForString_iPod4
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPod4,1"] == KMA_UIDeviceiPodTouch4), @"Expected iPod4,1 to return KMA_UIDeviceiPodTouch4");
}

- (void)testkmac_platformTypeForString_iPod5
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPod5,1"] == KMA_UIDeviceiPodTouch5), @"Expected iPod5,1 to return KMA_UIDeviceiPodTouch5");
}

- (void)testkmac_platformTypeForString_iPad1
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPad1,1"] == KMA_UIDeviceiPad1), @"Expected iPad1,1 to return KMA_UIDeviceiPad1");
}

- (void)testkmac_platformTypeForString_iPad2
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPad2,4"] == KMA_UIDeviceiPad2), @"Expected iPad2 with submodule <=4 to return KMA_UIDeviceiPad2");
}

- (void)testkmac_platformTypeForString_iPad2_mini
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPad2,5"] == KMA_UIDeviceiPadMini), @"Expected iPad2 with submodule >= 5 to return KMA_UIDeviceiPadMini");
}

- (void)testkmac_platformTypeForString_iPad3
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPad3,3"] == KMA_UIDeviceiPad3), @"Expected iPad3 with submodule <=3 to return KMA_UIDeviceiPad3");
}

- (void)testkmac_platformTypeForString_iPad4
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPad4,2"] == KMA_UIDeviceiPadAir), @"Expected iPad4 with submodule <=2 to return KMA_UIDeviceiPad4G");
}

- (void)testkmac_platformTypeForString_iPad4_mini
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPad4,4"] == KMA_UIDeviceiPadMini2), @"Expected iPad4 with submodule >=4 to return KMA_UIDeviceiPad4G");
}

- (void)testkmac_platformTypeForString_AppleTV2
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"AppleTV2"] == KMA_UIDeviceAppleTV2), @"Expected AppleTV2 to return KMA_UIDeviceAppleTV2");
}

- (void)testkmac_platformTypeForString_AppleTV3
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"AppleTV3"] == KMA_UIDeviceAppleTV3), @"Expected AppleTV3 to return KMA_UIDeviceAppleTV3");
}

- (void)testkmac_platformTypeForString_iPhone
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPhone"] == KMA_UIDeviceUnknowniPhone), @"Expected iPhone to return KMA_UIDeviceUnknowniPhone");
}

- (void)testkmac_platformTypeForString_iPod
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPod"] == KMA_UIDeviceUnknowniPod), @"Expected iPod to return KMA_UIDeviceUnknowniPod");
}

- (void)testkmac_platformTypeForString_iPad
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iPad"] == KMA_UIDeviceUnknowniPad), @"Expected iPad to return KMA_UIDeviceUnknowniPad");
}

- (void)testkmac_platformTypeForString_AppleTV
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"AppleTV"] == KMA_UIDeviceUnknownAppleTV), @"Expected AppleTV to return KMA_UIDeviceUnknownAppleTV");
}

- (void)testkmac_platformTypeForString_86
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"86"] == KMA_UIDeviceiPhoneSimulatoriPhone), @"Expected 86 with screen width < 768 to return KMA_UIDeviceiPhoneSimulatoriPhone");
}

- (void)testkmac_platformTypeForString_x86_64
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"x86_64"] == KMA_UIDeviceiPhoneSimulatoriPhone), @"Expected x86_64 with screen width < 768 to return KMA_UIDeviceiPhoneSimulatoriPhone");
}

- (void)testkmac_platformTypeForString_iTardis
{
    XCTAssert(([UIDevice kmac_platformTypeForString:@"iTardis"] == KMA_UIDeviceUnknown), @"Expected unexpected string to return KMA_UIDeviceUnknown");
}


@end
