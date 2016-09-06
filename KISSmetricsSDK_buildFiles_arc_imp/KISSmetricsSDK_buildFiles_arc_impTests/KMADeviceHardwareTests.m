//
// KISSmetricsSDK_buildFiles_arc_impTests
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


@interface KMADeviceHardwareTests : XCTestCase
@end


@implementation KMADeviceHardwareTests

- (void)testkmac_platformReturnsPlatfromString
{
    NSArray *expectedPlatforms = @[@"iFPGA",
                                   @"iPhone1,1", @"iPhone1,2", @"iPhone 3G", @"iPhone2,1", @"iPhone3,1", @"iPhone3,2", @"iPhone3,3", @"iPhone4,1", @"iPhone5,1", @"iPhone5,2", @"iPhone5,3", @"iPhone5,4", @"iPhone6,1", @"iPhone6,2",
                                   @"iPod1,1", @"iPod2,1", @"iPod2,2", @"iPod3,1", @"iPod4,1",
                                   @"ipad0,1", @"iPad1,1", @"iPad2,1", @"iPad2,2", @"iPad2,3", @"iPad2,4", @"iPad2,5", @"iPad2,6", @"iPad2,7", @"iPad3,1", @"iPad3,2", @"iPad3,3", @"iPad4,1", @"iPad4,2", @"iPad4,4", @"iPad4,5",
                                   @"iProd2,1",
                                   @"AppleTV2,1", @"AppleTV3,1",
                                   @"i386", @"x86_64"];
    
    // This value will vary based on simulator and device.
    // Ensure that the string matches one of the expected strings.
    NSString *platform = [[UIDevice currentDevice] kmac_platform];
    
    XCTAssertTrue([expectedPlatforms containsObject:platform], @"Expected test platfrom to be one of expected platforms but was not");
    // If this test is failing and you're running tests on a new device make sure this new device has been added to the KMA_UIDevicePlatform enum in UIDevice+KMAHarware.h AND expectedPlatforms array before you rip your hair out.
}


/*
- (void)testkmac_hwmodelReturnsHardwareModelString
{
    NSArray *expectedHardwareModels = @[@"MacBookPro10,1", // Macs
                                        @"N42AP", //iPhone5
                                        @"N78AP" //iPod5
                                        ];
    
    NSString *hardwareModel = [[UIDevice currentDevice] kmac_hwmodel];
    
    XCTAssertTrue([expectedHardwareModels containsObject:hardwareModel], @"Expected test hardware model to be one of expected hardware models but was not");
}
*/


// Minimal test of kmac_platformTypeForString
- (void)testkmac_platformTypeForStringReturnsPlatformEnum
{
    NSUInteger KMA_UIDeviceiPhoneSimulatoriPhone = 2;
    
    XCTAssertEqual(KMA_UIDeviceiPhoneSimulatoriPhone, [UIDevice kmac_platformTypeForString:@"86"], @"Expected platform enum for KMA_UIDeviceiPhoneSimulatoriPhone");
}


// Minimal test of kmac_platformStringForType
- (void)testkmac_platformStringForTypeReturnsPlatformString
{
    NSString *iPhone1 = @"iPhone 1";
    
    XCTAssertEqualObjects(iPhone1, [UIDevice kmac_platformStringForType:5], @"Expected platform string for iPhone 1");
}


// Minimal test of kmac_deviceFamily
- (void)testkmac_deviceFamilyReturnsDeviceFamilyEnumInExpectedRange
{
    NSUInteger deviceFamEnum = [[UIDevice currentDevice] kmac_deviceFamily];
    
    XCTAssert((deviceFamEnum >= 0 && deviceFamEnum <= 5), @"Expected device family enum to be in range");
}


// Minimal test of kmac_macaddress
- (void)testkmac_macaddressReturnsNonNilNSString
{
    NSString *macaddress = [[UIDevice currentDevice] kmac_macaddress];
    
    XCTAssert(([macaddress isKindOfClass:[NSString class]] && macaddress != nil && ![macaddress isEqualToString:@""]), @"");
}


@end
