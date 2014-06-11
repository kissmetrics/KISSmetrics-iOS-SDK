//
//  KMASender.h
//  KISSmetricsSDK_framework_builder
//
//  Created by William Rust on 6/9/14.
//  Copyright (c) 2014 KISSmetrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMAConnectionDelegateProtocol.h"
#import "KMASenderStateProtocol.h"

@class KMASenderReadyState;
@class KMASenderSendingState;
@class KMASenderDisabledState;
@class KMAConnection;


@interface KMASender : NSObject <KMAConnectionDelegate>

@property (nonatomic, strong) NSOperationQueue *connectionOpQueue;

@property (nonatomic, strong) id<KMASenderState> state;
@property (nonatomic, strong, readonly) KMASenderReadyState<KMASenderState> *readyState;
@property (nonatomic, strong, readonly) KMASenderSendingState<KMASenderState> *sendingState;
@property (nonatomic, strong, readonly) KMASenderDisabledState<KMASenderState> *disabledState;


- (id)initDisabled:(BOOL)disabled;

- (KMAConnection *)getNewConnection;

// Forwarded methods
- (void)startSending;
- (void)disableSending;
- (void)enableSending;


@end
