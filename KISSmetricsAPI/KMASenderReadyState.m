//
//  KMASenderReadyState.m
//  KISSmetricsSDK_framework_builder
//
//  Created by William Rust on 6/9/14.
//  Copyright (c) 2014 KISSmetrics. All rights reserved.
//

#import "KMASenderReadyState.h"
#import "KMASender.h"
#import "KMAArchiver.h"
#import "KMAConnection.h"

@interface KMASenderReadyState ()
@property (weak) KMASender *sender;
@end


@implementation KMASenderReadyState

- (id)initWithSender:(KMASender *)sender
{
    self = [super init];
    
    if (self != nil) {
        _sender = sender;
    }
    
    return self;
}



#pragma mark - Private methods
- (void)sendTopRecord
{
    NSString *queryString = [[KMAArchiver sharedArchiver] getQueryStringAtIndex:0];

    if (!queryString) {
        return;
    }

    // Assemble the full query string by prepending the current baseUrl as last archived.
    NSString *nextAPICall = [[KMAArchiver sharedArchiver] getBaseUrl];
    nextAPICall = [nextAPICall stringByAppendingString:queryString];
    KMAConnection *connection = [self.sender getNewConnection];
    [connection sendRecordWithURLString:nextAPICall delegate:self.sender];
}



#pragma mark - Forwarded methods
- (void)startSending
{
    // Ignore if we have nothing to send
    if ([KMAArchiver sharedArchiver].getQueueCount == 0) {
        return;
    }
    
    // Change to sendingState first so that sendingState is ready
    // to handle KMAConnectionDelegate's connectionSuccessful.
    [self.sender setState:self.sender.sendingState];
    
    // Begin sending
    [self.sender.connectionOpQueue addOperationWithBlock:^{@autoreleasepool{[self sendTopRecord];}}];
}


- (void)disableSending
{
    // Switch to disabled state first so that KMAConnectionDelegate's
    // connectionSuccessful is handled by the disabled state while we
    // clear the send queue.
    [self.sender setState:self.sender.disabledState];
    
    // Empty the archived send queue
    [[KMAArchiver sharedArchiver] clearSendQueue];
}


- (void)enableSending
{
    // Ignored, already enabled
}


- (void)connectionSuccessful:(BOOL)success
                forUrlString:(NSString *)urlString
          isMalformedRequest:(BOOL)malformed
{
    // Ignored, connectionComplete should only be handled by the sending state.
    // The only way that this method could be called in this state is if a record
    // is being sent at the time that the Sender is disabled and re-enabled.
    // We take no action because the queue would have already been emptied when
    // switching to the disabled state.
}


@end
