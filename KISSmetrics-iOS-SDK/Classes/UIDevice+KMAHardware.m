//
//  UIDevice+KMAHardware.m
//  KISSmetricsAPI_framework_builder
//
//  Renamed to avoid category name collision.
//
//  Derived from:
//  Erica Sadun, http://ericasadun.com
//  iPhone Developer's Cookbook, 6.x Edition
//  BSD License, Use at your own risk
//
//  Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.
//
//  https://github.com/willrust/uidevice-extension > https://github.com/othercat/uidevice-extension


#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>


#import "UIDevice+KMAHardware.h"

// Add support for subscripting to the iOS 5 SDK.
// reference from http://stackoverflow.com/questions/11658669/how-to-enable-the-new-objective-c-object-literals-on-ios
// also found from github https://github.com/tewha/iOS-Subscripting


#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000

@interface NSDictionary(KMAsubscripts)
- (id)kmac_objectForKeyedSubscript:(id)key;
@end

@interface NSMutableDictionary(KMAsubscripts)
- (void)kmac_setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end

@interface NSArray(KMAsubscripts)
- (id)kmac_objectAtIndexedSubscript:(NSUInteger)idx;
@end

@interface NSMutableArray(KMAsubscripts)
- (void)kmac_setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end

@implementation NSDictionary(KMAsubscripts)
- (id)kmac_objectForKeyedSubscript:(id)key;
{
    return [self objectForKey:key];
}
@end

#endif


@implementation UIDevice (KMAHardware)
/*
 Platforms

 iFPGA ->        ??

 iPhone1,1 ->    iPhone 1, M68
 iPhone1,2 ->    iPhone 3G, N82
 iPhone2,1 ->    iPhone 3GS, N88
 iPhone3,1 ->    iPhone 4/GSM, N89
 iPhone3,2 ->    iPhone 4/GSM Rev A, N90
 iPhone3,3 ->    iPhone 4/CDMA, N92
 iPhone4,1 ->    iPhone 4S/GSM+CDMA, N94
 iPhone5,1 ->    iPhone 5/GSM, N41
 iPhone5,2 ->    iPhone 5/GSM+CDMA, N42
 iPhone5,3 ->    iPhone 5C/GSM, N48
 iPhone5,4 ->    iPhone 5C/GSM+CDMA, N49
 iPhone6,1 ->    iPhone 5S/GSM, N51
 iPhone6,2 ->    iPhone 5S/GSM+CDMA, N53
 iPhone7,1 ->    iPhone 6 Plus, N56
 iPhone7,2 ->    iPhone 6, N61
 iPhone8,1 ->    iPhone 6S
 iPhone8,2 ->    iPhone 6 Plus

 iPod1,1   ->    iPod touch 1, N45
 iPod2,1   ->    iPod touch 2, N72
 iPod2,2   ->    iPod touch 3, Prototype
 iPod3,1   ->    iPod touch 3, N18
 iPod4,1   ->    iPod touch 4, N81
 iPod5.1   ->    iPod touch 5

 // Thanks NSForge
 ipad0,1   ->    iPad, Prototype
 iPad1,1   ->    iPad 1, WiFi and 3G, K48
 iPad2,1   ->    iPad 2, WiFi, K93
 iPad2,2   ->    iPad 2, GSM 3G, K94
 iPad2,3   ->    iPad 2, CDMA 3G, K95
 iPad2,4   ->    iPad 2, WiFi R2, K93A
 iPad2,5   ->    iPad mini, WIFI
 iPad2,6   ->    iPad mini, GSM
 iPad2,7   ->    iPad mini, GSM+CDMA
 iPad3,1   ->    iPad (3G), WiFi
 iPad3,2   ->    iPad (3G), CDMA
 iPad3,3   ->    iPad (3G), GSM
 iPad4,1   ->    iPad Air, WiFi
 iPad4,2   ->    iPad Air, Cellular
 iPad4,4   ->    iPad mini (2G), WiFi
 iPad4,5   ->    iPad mini (2G), Cellular (Verizon:GSM+CDMA, AT&T:GSM)

 iProd2,1   ->   AppleTV 2, Prototype
 AppleTV2,1 ->   AppleTV 2, K66
 AppleTV3,1 ->   AppleTV 3, ??

 i386, x86_64 -> iPhone Simulator
*/



#pragma mark sysctlbyname utils
- (NSString *) kma_getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);

    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);

    NSString *results = @(answer);

    free(answer);
    return results;
}


- (NSString *) kmac_platform
{
    return [self kma_getSysInfoByName:"hw.machine"];
}


// Thanks, Tom Harrington (Atomicbird)
- (NSString *) kmac_hwmodel
{
    return [self kma_getSysInfoByName:"hw.model"];
}



#pragma mark sysctl utils
- (NSUInteger) kma_getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(NSInteger);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}


- (NSUInteger) kmac_cpuFrequency
{
    return [self kma_getSysInfo:HW_CPU_FREQ];
}


- (NSUInteger) kmac_busFrequency
{
    return [self kma_getSysInfo:HW_BUS_FREQ];
}


- (NSUInteger) kmac_cpuCount
{
    return [self kma_getSysInfo:HW_NCPU];
}


- (NSUInteger) kmac_totalMemory
{
    return [self kma_getSysInfo:HW_PHYSMEM];
}


- (NSUInteger) kmac_userMemory
{
    return [self kma_getSysInfo:HW_USERMEM];
}


- (NSUInteger) kma_maxSocketBufferSize
{
    return [self kma_getSysInfo:KIPC_MAXSOCKBUF];
}



#pragma mark file system -- Thanks Joachim Bean!

/*
 extern NSString *NSFileSystemSize;
 extern NSString *NSFileSystemFreeSize;
 extern NSString *NSFileSystemNodes;
 extern NSString *NSFileSystemFreeNodes;
 extern NSString *NSFileSystemNumber;
 */

- (NSNumber *) kmac_totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return fattributes[NSFileSystemSize];
}


- (NSNumber *) kmac_freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return fattributes[NSFileSystemFreeSize];
}


+( NSInteger )kma_getSubmodel:( NSString* )platform //private
{
    NSInteger submodel = -1;

    NSArray* components = [ platform componentsSeparatedByString:@"," ];
    if ( [ components count ] >= 2 ) {
        submodel = [ [ components objectAtIndex:1 ] intValue ];
    }
    return submodel;
}



#pragma mark platform type and name utils

- (NSUInteger) kmac_platformType
{
    return [UIDevice kmac_platformTypeForString:[self kmac_platform]];
}


- (NSString *) kmac_platformString
{
    return [UIDevice kmac_platformStringForType:[self kmac_platformType]];
}


+ (NSUInteger) kmac_platformTypeForString:(NSString *)platform
{
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return KMA_UIDeviceIFPGA;

    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return KMA_UIDeviceiPhone1;
    if ([platform isEqualToString:@"iPhone1,2"])    return KMA_UIDeviceiPhone3G;
    if ([platform hasPrefix:@"iPhone2"])            return KMA_UIDeviceiPhone3GS;
    if ([platform isEqualToString:@"iPhone3,1"])    return KMA_UIDeviceiPhone4GSM;
    if ([platform isEqualToString:@"iPhone3,2"])    return KMA_UIDeviceiPhone4GSMRevA;
    if ([platform isEqualToString:@"iPhone3,3"])    return KMA_UIDeviceiPhone4CDMA;
    if ([platform hasPrefix:@"iPhone4"])            return KMA_UIDeviceiPhone4S;
    if ([platform isEqualToString:@"iPhone5,1"])    return KMA_UIDeviceiPhone5GSM;
    if ([platform isEqualToString:@"iPhone5,2"])    return KMA_UIDeviceiPhone5GSMCDMA;
    if ([platform isEqualToString:@"iPhone5,3"])    return KMA_UIDeviceiPhone5CGSM;
    if ([platform isEqualToString:@"iPhone5,4"])    return KMA_UIDeviceiPhone5CGSMCDMA;
    if ([platform isEqualToString:@"iPhone6,1"])    return KMA_UIDeviceiPhone5SGSM;
    if ([platform isEqualToString:@"iPhone6,2"])    return KMA_UIDeviceiPhone5SGSMCDMA;
    if ([platform isEqualToString:@"iPhone7,1"])    return KMA_UIDeviceiPhone6Plus;
    if ([platform isEqualToString:@"iPhone7,2"])    return KMA_UIDeviceiPhone6;
    if ([platform isEqualToString:@"iPhone8,1"])    return KMA_UIDeviceiPhone6S;
    if ([platform isEqualToString:@"iPhone8,2"])    return KMA_UIDeviceiPhone6SPlus;

    // iPod
    if ([platform hasPrefix:@"iPod1"])              return KMA_UIDeviceiPodTouch1;
    if ([platform isEqualToString:@"iPod2,2"])      return KMA_UIDeviceiPodTouch3;
    if ([platform hasPrefix:@"iPod2"])              return KMA_UIDeviceiPodTouch2;
    if ([platform hasPrefix:@"iPod3"])              return KMA_UIDeviceiPodTouch3;
    if ([platform hasPrefix:@"iPod4"])              return KMA_UIDeviceiPodTouch4;
    if ([platform hasPrefix:@"iPod5"])              return KMA_UIDeviceiPodTouch5;

    // iPad
    if ([platform hasPrefix:@"iPad1"])              return KMA_UIDeviceiPad1;
    if ([platform hasPrefix:@"iPad2"]) {

        NSInteger submodel = [ UIDevice kma_getSubmodel:platform ];
        if (submodel <= 4) {
            return KMA_UIDeviceiPad2;
        }
        else if (submodel <=7) {
            // iPad2,5 iPad2,6 iPad2,7
            return KMA_UIDeviceiPadMini;
        }
    }

    if ([platform hasPrefix:@"iPad3"]) {

        NSInteger submodel = [ UIDevice kma_getSubmodel:platform ];
        if (submodel <= 3) {
            return KMA_UIDeviceiPad3;
        }
        else if (submodel <=6 ) {
            // iPad3,4 iPad3,5 iPad3,6
            return KMA_UIDeviceiPad4;
        }
    }

    if ([platform hasPrefix:@"iPad4"]) {

        NSInteger submodel = [ UIDevice kma_getSubmodel:platform ];
        if (submodel <= 2) {
            return KMA_UIDeviceiPadAir;
        }
        else if (submodel <=5) {
            // iPad4,4 iPad4,5
            return KMA_UIDeviceiPadMini2;
        }
    }

    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])   return KMA_UIDeviceAppleTV2;
    if ([platform hasPrefix:@"AppleTV3"])   return KMA_UIDeviceAppleTV3;

    if ([platform hasPrefix:@"iPhone"])     return KMA_UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])       return KMA_UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])       return KMA_UIDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"])    return KMA_UIDeviceUnknownAppleTV;

    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"]) {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? KMA_UIDeviceiPhoneSimulatoriPhone : KMA_UIDeviceiPhoneSimulatoriPad;
    }

    return KMA_UIDeviceUnknown;
}


+ (NSString *) kmac_platformStringForType:(NSUInteger)platformType
{
	switch (platformType)
    {
        case KMA_UIDeviceiPhone1:               return KMA_IPHONE_1_NAMESTRING;
        case KMA_UIDeviceiPhone3G:              return KMA_IPHONE_3G_NAMESTRING;
        case KMA_UIDeviceiPhone3GS:             return KMA_IPHONE_3GS_NAMESTRING;
        case KMA_UIDeviceiPhone4GSM:            return KMA_IPHONE_4_NAMESTRING;
        case KMA_UIDeviceiPhone4GSMRevA:        return KMA_IPHONE_4_NAMESTRING;
        case KMA_UIDeviceiPhone4CDMA:           return KMA_IPHONE_4_NAMESTRING;
        case KMA_UIDeviceiPhone4S:              return KMA_IPHONE_4S_NAMESTRING;
        case KMA_UIDeviceiPhone5GSM:            return KMA_IPHONE_5_NAMESTRING;
        case KMA_UIDeviceiPhone5GSMCDMA:        return KMA_IPHONE_5_NAMESTRING;
        case KMA_UIDeviceiPhone5CGSM:           return KMA_IPHONE_5C_NAMESTRING;
        case KMA_UIDeviceiPhone5CGSMCDMA:       return KMA_IPHONE_5C_NAMESTRING;
        case KMA_UIDeviceiPhone5SGSM:           return KMA_IPHONE_5S_NAMESTRING;
        case KMA_UIDeviceiPhone5SGSMCDMA:       return KMA_IPHONE_5S_NAMESTRING;
        case KMA_UIDeviceiPhone6:               return KMA_IPHONE_6_NAMESTRING;
        case KMA_UIDeviceiPhone6Plus:           return KMA_IPHONE_6PLUS_NAMESTRING;
        case KMA_UIDeviceiPhone6S:              return KMA_IPHONE_6S_NAMESTRING;
        case KMA_UIDeviceiPhone6SPlus:          return KMA_IPHONE_6SPLUS_NAMESTRING;
        case KMA_UIDeviceUnknowniPhone:         return KMA_IPHONE_UNKNOWN_NAMESTRING;

        case KMA_UIDeviceiPodTouch1:            return KMA_IPOD_TOUCH_1_NAMESTRING;
        case KMA_UIDeviceiPodTouch2:            return KMA_IPOD_TOUCH_2_NAMESTRING;
        case KMA_UIDeviceiPodTouch3:            return KMA_IPOD_TOUCH_3_NAMESTRING;
        case KMA_UIDeviceiPodTouch4:            return KMA_IPOD_TOUCH_4_NAMESTRING;
        case KMA_UIDeviceiPodTouch5:            return KMA_IPOD_TOUCH_5_NAMESTRING;
        case KMA_UIDeviceUnknowniPod:           return KMA_IPOD_UNKNOWN_NAMESTRING;

        case KMA_UIDeviceiPad1:                 return KMA_IPAD_1_NAMESTRING;
        case KMA_UIDeviceiPad2:                 return KMA_IPAD_2_NAMESTRING;
        case KMA_UIDeviceiPad3:                 return KMA_IPAD_3G_NAMESTRING;
        case KMA_UIDeviceiPad4:                 return KMA_IPAD_4G_NAMESTRING;
        case KMA_UIDeviceiPadMini:              return KMA_IPAD_MINI_NAMESTRING;
        case KMA_UIDeviceiPadMini2:             return KMA_IPAD_MINI_2G_NAMESTRING;
        case KMA_UIDeviceiPadAir:               return KMA_IPAD_AIR_NAMESTRING;
        case KMA_UIDeviceUnknowniPad:           return KMA_IPAD_UNKNOWN_NAMESTRING;

        case KMA_UIDeviceAppleTV2:              return KMA_APPLETV_2G_NAMESTRING;
        case KMA_UIDeviceAppleTV3:              return KMA_APPLETV_3G_NAMESTRING;
        case KMA_UIDeviceAppleTV4:              return KMA_APPLETV_4G_NAMESTRING;
        case KMA_UIDeviceUnknownAppleTV:        return KMA_APPLETV_UNKNOWN_NAMESTRING;

        case KMA_UIDeviceiPhoneSimulator:       return KMA_IPHONE_SIMULATOR_NAMESTRING;
        case KMA_UIDeviceiPhoneSimulatoriPhone: return KMA_IPHONE_SIMULATOR_IPHONE_NAMESTRING;
        case KMA_UIDeviceiPhoneSimulatoriPad:   return KMA_IPHONE_SIMULATOR_IPAD_NAMESTRING;
        case KMA_UIDeviceSimulatorAppleTV:      return KMA_SIMULATOR_APPLETV_NAMESTRING;

        case KMA_UIDeviceIFPGA:                 return KMA_IFPGA_NAMESTRING;

        default:                                return KMA_IOS_FAMILY_UNKNOWN_DEVICE;
    }
}


+ (NSString *) kmac_platformStringForPlatform:(NSString *)platform
{
	NSUInteger platformType = [UIDevice kmac_platformTypeForString:platform];
	return [UIDevice kmac_platformStringForType:platformType];
}


+ (BOOL) kmac_hasRetinaDisplay
{
    return ([UIScreen mainScreen].scale == 2.0f);
}


+ (NSString *) kmac_imageSuffixRetinaDisplay
{
    return @"@2x";
}


+ (BOOL) kmac_has4InchDisplay
{
    return ([UIScreen mainScreen].bounds.size.height == 568);
}


+ (NSString *) kmac_imageSuffix4InchDisplay
{
    return @"-568h";
}


- (KMA_UIDeviceFamily) kmac_deviceFamily
{
    NSString *platform = [self kmac_platform];
    if ([platform hasPrefix:@"iPhone"]) return KMA_UIDeviceFamilyiPhone;
    if ([platform hasPrefix:@"iPod"]) return KMA_UIDeviceFamilyiPod;
    if ([platform hasPrefix:@"iPad"]) return KMA_UIDeviceFamilyiPad;
    if ([platform hasPrefix:@"AppleTV"]) return KMA_UIDeviceFamilyAppleTV;

    return KMA_UIDeviceFamilyUnknown;
}



#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) kmac_macaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;

    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;

    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }

    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }

    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }

    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return outstring;
}


@end
