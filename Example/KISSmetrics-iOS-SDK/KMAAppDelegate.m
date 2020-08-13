//
//  KMAAppDelegate.m
//  KISSmetrics-iOS-SDK
//
//  Copyright (c) 2020 KISSmetrics. All rights reserved.
//

#import "KMAAppDelegate.h"

@import KISSmetrics_iOS_SDK;

@implementation KMAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (![self isRunningTest]) {

        [KISSmetricsAPI sharedAPIWithKey:@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"];
        
        [[KISSmetricsAPI sharedAPI] record:@"/app_launched"];
    }
    
    return YES;
}

- (BOOL)isRunningTest {
    
    return [[[NSProcessInfo processInfo] environment] valueForKey:@"XCTestConfigurationFilePath"] != nil;
}

@end
