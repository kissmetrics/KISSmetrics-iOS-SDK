//
// KISSmetricsSDK_buildFiles_arc_impTests
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

// Test support
#import <XCTest/XCTest.h>


@interface KMAArchiverTests : XCTestCase
@end

@implementation KMAArchiverTests
{
    // test fixture ivars go here
}

- (void)testAppVersionKeychainSetter
{
    // Clean the KMAAppVersion keychain
    KMAKeychainItemWrapper *keychainItem = [[KMAKeychainItemWrapper alloc] initWithIdentifier:@"KMAAppVersion" accessGroup:nil];

    // Set an app version string using the setter method
    NSString *appVersionString = @"1.2.3";
    [KMAArchiver sharedArchiver].keychainAppVersion = appVersionString;

    // Get the app version string directly
    NSString *resultVersionString = (NSString *)[keychainItem objectForKey:(__bridge id)kSecAttrGeneric];
    
    NSLog(@"resultVersionString = %@", resultVersionString);
    
    XCTAssertEqualObjects(resultVersionString, appVersionString, @"Stored keychain value matches");
}


- (void)testAppVersionKeychainGetter
{
    // Clean the KMAAppVersion keychain
    KMAKeychainItemWrapper *keychainItem = [[KMAKeychainItemWrapper alloc] initWithIdentifier:@"KMAAppVersion" accessGroup:nil];
 
    // Set an app version string directly
    NSString *appVersionString = @"1.2.3";
    [keychainItem setObject:appVersionString forKey:(__bridge id)kSecAttrGeneric];

    // Get the app version string using the getter method
    NSString *resultVersionString = [KMAArchiver sharedArchiver].keychainAppVersion;
    
    NSLog(@"resultVersionString = %@", resultVersionString);
    
    XCTAssertEqualObjects(resultVersionString, appVersionString, @"Stored keychain value matches");
}


- (void)testSettingOtherKeys
{
    // Setting a value for the same key on a different keychain does not change KMAAppVersion keychain value
    KMAKeychainItemWrapper *otherKeychainItem = [[KMAKeychainItemWrapper alloc] initWithIdentifier:@"CustomerIdentifier" accessGroup:nil];
    [otherKeychainItem setObject:@"dataSetByCustomer" forKey:(__bridge id)kSecAttrGeneric];
    
    NSString *resultVersionString = (NSString *)[otherKeychainItem objectForKey:(__bridge id)kSecAttrGeneric];
    
    XCTAssertEqualObjects(resultVersionString, @"dataSetByCustomer", @"Stored keychain value matches");
}

@end
