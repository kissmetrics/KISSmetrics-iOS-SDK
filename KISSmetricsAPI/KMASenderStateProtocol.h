//
//  KMASenderStateProtocol.h
//  KISSmetricsSDK_framework_builder
//
//  Created by William Rust on 6/9/14.
//  Copyright (c) 2014 KISSmetrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMAConnectionDelegateProtocol.h"
@class KMASender;

@protocol KMASenderState <KMAConnectionDelegate>

@required

 // Initializer
 - (id)initWithSender:(KMASender *)sender;

 // Switches to sendingState and starts sending from the top of the send queue if appropriate.
 - (void)startSending;

 // Switches to the disabled state if appropriate
 - (void)disableSending;

 // Switches to an enabled state if appropriate
 - (void)enableSending;

@end
