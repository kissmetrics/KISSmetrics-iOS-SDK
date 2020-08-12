//
//  KMASenderDisabledState.m
//  KISSmetricsSDK_framework_builder
//
//  Created by William Rust on 6/9/14.
//  Copyright (c) 2014 KISSmetrics. All rights reserved.
//

#import "KMASenderDisabledState.h"
#import "KMASender.h"

@interface KMASenderDisabledState ()
@property (weak) KMASender *sender;
@end


@implementation KMASenderDisabledState

- (id)initWithSender:(KMASender *)sender
{
    self = [super init];
    
    if (self != nil) {
        _sender = sender;
    }
    
    return self;
}



#pragma mark - Forwarded methods
- (void)startSending
{
    // Ignored. Sending is disabled
}


- (void)disableSending
{
    // Ignored. Already in disabled state
}


- (void)enableSending
{
    [self.sender setState:self.sender.readyState];
}


- (void)connectionSuccessful:(BOOL)success
                forUrlString:(NSString *)urlString
          isMalformedRequest:(BOOL)malformed
{
    // Ignored. The queue should already be empty as a result of switching to a disabled state.
}


@end
