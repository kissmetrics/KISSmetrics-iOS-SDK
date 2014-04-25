//
//  UIDevice+KMAHardware.h
//  KISSmetricsAPI_framework_builder
//
//  Renamed to avoid category name conflict.
//
//  Derived from:
//  Erica Sadun, http://ericasadun.com
//  iPhone Developer's Cookbook, 6.x Edition
//  BSD License, Use at your own risk
//

#import <UIKit/UIKit.h>

#define KMA_IFPGA_NAMESTRING                @"iFPGA"

#define KMA_IPHONE_1_NAMESTRING             @"iPhone 1"
#define KMA_IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define KMA_IPHONE_3GS_NAMESTRING           @"iPhone 3GS"
#define KMA_IPHONE_4_NAMESTRING             @"iPhone 4"
#define KMA_IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define KMA_IPHONE_5_NAMESTRING             @"iPhone 5"
#define KMA_IPHONE_5C_NAMESTRING            @"iPhone 5C"
#define KMA_IPHONE_5S_NAMESTRING            @"iPhone 5S"
#define KMA_IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define KMA_IPOD_TOUCH_1_NAMESTRING         @"iPod touch 1"
#define KMA_IPOD_TOUCH_2_NAMESTRING         @"iPod touch 2"
#define KMA_IPOD_TOUCH_3_NAMESTRING         @"iPod touch 3"
#define KMA_IPOD_TOUCH_4_NAMESTRING         @"iPod touch 4"
#define KMA_IPOD_TOUCH_5_NAMESTRING         @"iPod touch 5"
#define KMA_IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define KMA_IPAD_1_NAMESTRING               @"iPad 1"
#define KMA_IPAD_2_NAMESTRING               @"iPad 2"
#define KMA_IPAD_3G_NAMESTRING              @"iPad (3G)"
#define KMA_IPAD_4G_NAMESTRING              @"iPad (4G)"
#define KMA_IPAD_MINI_NAMESTRING            @"iPad mini"
#define KMA_IPAD_MINI_2G_NAMESTRING         @"iPad mini (2G)"
#define KMA_IPAD_AIR_NAMESTRING             @"iPad Air"
#define KMA_IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define KMA_APPLETV_2G_NAMESTRING           @"Apple TV 2"
#define KMA_APPLETV_3G_NAMESTRING           @"Apple TV 3"
#define KMA_APPLETV_4G_NAMESTRING           @"Apple TV 4"
#define KMA_APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define KMA_IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define KMA_IPHONE_SIMULATOR_NAMESTRING         @"iPhone Simulator"
#define KMA_IPHONE_SIMULATOR_IPHONE_NAMESTRING  @"iPhone Simulator"
#define KMA_IPHONE_SIMULATOR_IPAD_NAMESTRING    @"iPad Simulator"

#define KMA_SIMULATOR_APPLETV_NAMESTRING        @"Apple TV Simulator"

typedef enum {
    KMA_UIDeviceUnknown,
    
    KMA_UIDeviceiPhoneSimulator,
    KMA_UIDeviceiPhoneSimulatoriPhone, // Both regular and iPhone 4 devices
    KMA_UIDeviceiPhoneSimulatoriPad,
    KMA_UIDeviceSimulatorAppleTV,
    
    KMA_UIDeviceiPhone1,
    KMA_UIDeviceiPhone3G,
    KMA_UIDeviceiPhone3GS,
    KMA_UIDeviceiPhone4,
    KMA_UIDeviceiPhone4GSM,
    KMA_UIDeviceiPhone4GSMRevA,
    KMA_UIDeviceiPhone4CDMA,
    KMA_UIDeviceiPhone4S,
    KMA_UIDeviceiPhone5,
    KMA_UIDeviceiPhone5GSM,
    KMA_UIDeviceiPhone5GSMCDMA,
    KMA_UIDeviceiPhone5CGSM,
    KMA_UIDeviceiPhone5CGSMCDMA,
    KMA_UIDeviceiPhone5SGSM,
    KMA_UIDeviceiPhone5SGSMCDMA,
    
    KMA_UIDeviceiPodTouch1,
    KMA_UIDeviceiPodTouch2,
    KMA_UIDeviceiPodTouch3,
    KMA_UIDeviceiPodTouch4,
    KMA_UIDeviceiPodTouch5,
    
    KMA_UIDeviceiPad1,
    KMA_UIDeviceiPad2,
    KMA_UIDeviceiPad3,
    KMA_UIDeviceiPad4,
    KMA_UIDeviceiPadMini,
    KMA_UIDeviceiPadMini2,
    KMA_UIDeviceiPadAir,

    KMA_UIDeviceAppleTV2,
    KMA_UIDeviceAppleTV3,
    KMA_UIDeviceAppleTV4,
    
    KMA_UIDeviceUnknowniPhone,
    KMA_UIDeviceUnknowniPod,
    KMA_UIDeviceUnknowniPad,
    KMA_UIDeviceUnknownAppleTV,
    KMA_UIDeviceIFPGA,
    
} KMA_UIDevicePlatform;

typedef enum {
    KMA_UIDeviceFamilyiPhone,
    KMA_UIDeviceFamilyiPod,
    KMA_UIDeviceFamilyiPad,
    KMA_UIDeviceFamilyAppleTV,
    KMA_UIDeviceFamilyUnknown,
    
} KMA_UIDeviceFamily;

@interface UIDevice (KMAHardware)
- (NSString *) kmac_platform;
- (NSString *) kmac_hwmodel;
- (NSUInteger) kmac_platformType;
- (NSString *) kmac_platformString;

- (NSUInteger) kmac_cpuFrequency;
- (NSUInteger) kmac_busFrequency;
- (NSUInteger) kmac_cpuCount;
- (NSUInteger) kmac_totalMemory;
- (NSUInteger) kmac_userMemory;

- (NSNumber *) kmac_totalDiskSpace;
- (NSNumber *) kmac_freeDiskSpace;

- (NSString *) kmac_macaddress;

+ (NSUInteger) kmac_platformTypeForString:(NSString *)platform;
+ (NSString *) kmac_platformStringForType:(NSUInteger)platformType;
+ (NSString *) kmac_platformStringForPlatform:(NSString *)platform;

+ (BOOL) kmac_hasRetinaDisplay;
+ (NSString *) kmac_imageSuffixRetinaDisplay;
+ (BOOL) kmac_has4InchDisplay;
+ (NSString *) kmac_imageSuffix4InchDisplay;

- (KMA_UIDeviceFamily) kmac_deviceFamily;

@end
