#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KISSmetricsAPI.h"
#import "KISSmetricsAPI_options.h"
#import "KMAArchiver.h"
#import "KMAConnection.h"
#import "KMAConnectionDelegateProtocol.h"
#import "KMAKeychainItemWrapper.h"
#import "KMAQueryEncoder.h"
#import "KMASender.h"
#import "KMASenderDisabledState.h"
#import "KMASenderReadyState.h"
#import "KMASenderSendingState.h"
#import "KMASenderStateProtocol.h"
#import "KMASwizzler.h"
#import "KMATrackingOperations.h"
#import "KMATrackingOperations_NonTrackingState.h"
#import "KMATrackingOperations_TrackingState.h"
#import "KMAVerification.h"
#import "KMAVerificationDelegateProtocol.h"
#import "UIDevice+KMAHardware.h"
#import "UIViewController+KMAVCLifecycle.h"

FOUNDATION_EXPORT double KissmetricsSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char KissmetricsSDKVersionString[];

