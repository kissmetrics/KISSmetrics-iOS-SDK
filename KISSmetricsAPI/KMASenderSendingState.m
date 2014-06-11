//
//  KMASenderSendingState.m
//  KISSmetricsSDK_framework_builder
//
//  Created by William Rust on 6/9/14.
//  Copyright (c) 2014 KISSmetrics. All rights reserved.
//

#import "KMASenderSendingState.h"
#import "KMASender.h"
#import "KMAArchiver.h"
#import "KMAConnection.h"

@interface KMASenderSendingState ()
@property (weak) KMASender *sender;
@end


@implementation KMASenderSendingState

// Initializer
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
    // Assemble the full query string by prepending the current baseUrl as last archived.
    NSString *nextAPICall = [[KMAArchiver sharedArchiver] getBaseUrl];
    nextAPICall = [nextAPICall stringByAppendingString:[[KMAArchiver sharedArchiver] getQueryStringAtIndex:0]];
    KMAConnection *connection = [self.sender getNewConnection];
    [connection sendRecordWithURLString:nextAPICall delegate:self.sender];
}



#pragma mark - Forwarded methods
- (void)startSending
{
    // Ignored. We're already sending.
}


- (void)disableSending
{
    [self.sender.connectionOpQueue cancelAllOperations];
    
    // Switch to disabled state first so that KMAConnectionDelegate's
    // connectionSuccessful is handled by the disabled state while we
    // clear the send queue.
    [self.sender setState:self.sender.disabledState];
    
    // Empty the archived send queue
    [[KMAArchiver sharedArchiver] clearSendQueue];
}


- (void)enableSending
{
    // Ignored. Already enabled.
}


- (void)connectionSuccessful:(BOOL)success
                forUrlString:(NSString *)urlString
          isMalformedRequest:(BOOL)malformed
{
    // If the request was successful or malformed(unusable) we remove it from the queue.
    if (success || malformed) {
        [[KMAArchiver sharedArchiver] removeQueryStringAtIndex:0];
    }
    
    if (success) {
       
        // If there's nothing left to send, switch to the ready state
        if ([KMAArchiver sharedArchiver].getQueueCount == 0) {
            [self.sender.connectionOpQueue cancelAllOperations];
            [self.sender setState:self.sender.readyState];
            
            return;
        }
        
        // Begin sending the next record
        [self.sender.connectionOpQueue addOperationWithBlock:^{@autoreleasepool{[self sendTopRecord];}}];
        
    }
    else {
        
        // Failure to succeed will likely be due to connectivity issues.
        // Stop sending and place the Sender in a ready state.
        [self.sender.connectionOpQueue cancelAllOperations];
        [self.sender setState:self.sender.readyState];
    }
}


@end
