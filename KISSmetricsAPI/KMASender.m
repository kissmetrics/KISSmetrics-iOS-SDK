//
//  KMASender.m
//  KISSmetricsSDK_framework_builder
//
//  Created by William Rust on 6/9/14.
//  Copyright (c) 2014 KISSmetrics. All rights reserved.
//

#import "KMASender.h"

#import "KMASenderReadyState.h"
#import "KMASenderSendingState.h"
#import "KMASenderDisabledState.h"

#import "KMAConnection.h"


@implementation KMASender

- (id)initDisabled:(BOOL)disabled
{
    self = [super init];
    
    if (self != nil) {

        _connectionOpQueue = [NSOperationQueue new];
        [_connectionOpQueue setMaxConcurrentOperationCount:1];
        [_connectionOpQueue setName:@"KMASenderOpQueue"];
        
        _readyState = [[KMASenderReadyState alloc] initWithSender:self];
        _sendingState = [[KMASenderSendingState alloc] initWithSender:self];
        _disabledState = [[KMASenderDisabledState alloc] initWithSender:self];
        
        if (disabled) {
            _state = _disabledState;
        }
        else {
            _state = _readyState;
        }
    }
    
    return self;
}

-(KMAConnection *)getNewConnection
{
    return [KMAConnection new];
}


#pragma mark - Forwarded methods
- (void)startSending
{
    @synchronized(self) {
        [self.state startSending];
    }
}

- (void)disableSending
{
    @synchronized(self) {
        [self.state disableSending];
    }
}

- (void)enableSending
{
    @synchronized(self) {
        [self.state enableSending];
    }
}


#pragma mark - KMAConnectionDelegate methods
- (void)connectionSuccessful:(BOOL)success
                forUrlString:(NSString *)urlString
          isMalformedRequest:(BOOL)malformed
{
    @synchronized(self) {
        [self.state connectionSuccessful:success
                            forUrlString:urlString
                      isMalformedRequest:malformed];
    }
}

@end
