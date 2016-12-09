//
// KISSmetricsSDK
//
// KMAConnection.m
//
// Handles URLRequests to upload events and properties from KMAArchiver's send queue.
//
// This class will hold it's calling thread until the URLConnection is complete or times out.
// This is to prevent multiple KMAConnection classes from concurrently attempting to upload the
// same archived event or propery from KMAArchiver's send queue.
//
// Copyright 2014 KISSmetrics
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.



#import "KMAMacros.c"
#import "KMAConnection.h"
#import "KMAArchiver.h"

static float const kKMAConnectionTimeout = 20.0f;


@implementation KMAConnection {
    NSURLConnection *_connection;
    NSString *_urlString;
}



#pragma mark - private methods
// Initializes a NSURLConnection.
// Allows for injection of mock NSURLConnection via method override.
- (NSURLConnection *)kma_createNSURLConnectionWithRequest:(NSURLRequest *)request
                                                 delegate:(id < NSURLConnectionDelegate >)delegate
                                         startImmediately:(BOOL)startImmediately {
    return [[NSURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:startImmediately];
}



#pragma mark - public methods
- (void)sendRecordWithURLString:(NSString *)urlString delegate:(id <KMAConnectionDelegate>)delegate
{
    KMALog(@"KMAConnection sendRecordWithURLString:%@ delegate", urlString);
    
    // Retain delegate for completion calls
    self.delegate = delegate;
    
    // Retain the urlString, we'll need to pass this back to the delegate
    _urlString = urlString;
    
    // We use the default cachePolicy but set our own timeoutInterval
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:kKMAConnectionTimeout];
    // ----- Runloop retention
    // Attempting to keep connection running in current thread without
    // manually holding up the runloop unti we get success or failure.
    // !!!: Watch for issues with iOS5 and scheduleInRunLoop :
    //_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    _connection = [self kma_createNSURLConnectionWithRequest:request delegate:self startImmediately:NO];
    
    // Since we're running all of our connections through NSInvocations on an NSOperationQueue,
    // we can set the NSURLConnection's delegateQueue and not have to manipulate the NSRunLoop ourselves
    
    // An issue exist in >iOS5 <iOS6 where setDelegatQueue does not work as expected.
    // See open rdar: http://openradar.appspot.com/10529053
    //[_connection setDelegateQueue:[NSOperationQueue currentQueue]];
    
    // We'll rely on the old way until we drop support for < iOS 6
    // setDelegateQueue workaround ---- (1/4)
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    // --------------------------------
    
    [_connection start];
    
    // setDelegateQueue workaround ---- (2/4)
    // Keep the runloop or delegate will not be called.
    CFRunLoopRun();
    // --------------------------------
}



# pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    KMALog(@"KMAConnection connection didReceiveResponse");
    
    if (self.delegate && response) {
        
        // Cast the response to NSHTTPURLResponse to get status code
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if ([httpResponse statusCode] == 200 ||
            [httpResponse statusCode] == 304) {
            KMALog(@"KISSmetricsAPI.m nsi_recursiveSend: httpResponseCode:%li", (long)[httpResponse statusCode]);
            
            // Success
            [self.delegate connectionSuccessful:YES forUrlString:_urlString isMalformedRequest:NO];
        }
        else {
            // Failure
            [self.delegate connectionSuccessful:NO forUrlString:_urlString isMalformedRequest:NO];
        }
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // setDelegateQueue workaround ---- (3/4)
    CFRunLoopStop(CFRunLoopGetCurrent());
    // --------------------------------
}



# pragma mark - NSURLConnectionDelegate methods

// Sent when a connection fails to load its request successfully.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.delegate && error) {
        
        if (error.code == NSURLErrorBadURL ||
            error.code == NSURLErrorUnsupportedURL ||
            error.code == NSURLErrorDataLengthExceedsMaximum) {
            
            [self.delegate connectionSuccessful:NO forUrlString:_urlString isMalformedRequest:YES];
        }else{
            [self.delegate connectionSuccessful:NO forUrlString:_urlString isMalformedRequest:NO];
        }
    }
    
    // setDelegateQueue workaround ---- (4/4)
    CFRunLoopStop(CFRunLoopGetCurrent());
    // --------------------------------
}



#pragma mark - Private Unit Testing Helpers

- (NSURLConnection *)uth_getConnection {
    return _connection;
}

- (NSString *)uth_getUrlString; {
    return _urlString;
}


@end
