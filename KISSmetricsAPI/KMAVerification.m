//
// KISSmetricsSDK
//
// KMAVerification.m
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
#import "KMAVerification.h"

static float const kKMAVerificationTimeout = 20.0f;
static NSString * const kKMAVerificationUrl = @"https://et.kissmetrics.com/m/trk";


@implementation KMAVerification {
    
    NSURLConnection *_connection;
    NSMutableData   *_buffer;
    NSString *_expiresHeaderString;
    
    BOOL _success;
    NSNumber *_expirationDate;
    BOOL _doTrack;
    NSString *_baseUrl;
}


#pragma mark - private methods
// Initializes a NSURLConnection.
// Allows for injection of mock NSURLConnection via method override.
- (NSURLConnection *)kma_createNSURLConnectionWithRequest:(NSURLRequest *)request
                                                 delegate:(id < NSURLConnectionDelegate >)delegate
                                         startImmediately:(BOOL)startImmediately {
    return [[NSURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

- (NSDateFormatter *)kma_dateFormatter
{
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [_dateFormatter setDateFormat:@"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"];
    });
    return _dateFormatter;
}

- (NSNumber *)kma_unixTimestampFromDateString:(NSString *)dateString
{
    // Convert expiration date string to unix timestamp
    return @([[[self kma_dateFormatter] dateFromString:dateString] timeIntervalSince1970]);
}


#pragma mark - public methods
- (void)verifyTrackingForProductKey:(NSString*)productKey
                         installUuid:(NSString*)installUuid
                            delegate:(id <KMAVerificationDelegate>)delegate
{
    // Default values
    _success = NO;
    _expirationDate = 0;
    _doTrack = YES; // We should always track by default. But we may not always send.
    _baseUrl = @"";
    
    self.delegate = delegate;
    
    _buffer = [NSMutableData data];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?product_key=%@&install_uuid=%@",
                           kKMAVerificationUrl, productKey, installUuid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:kKMAVerificationTimeout];
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
    // Reset the buffer
    [_buffer setLength:0];
    
    // Record the expires header value
    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
    _expiresHeaderString = [headers objectForKey:@"Expires"];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_buffer appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *jsonParsingError = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:_buffer options:0 error:&jsonParsingError];
    
    if (!jsonParsingError) {
        // Parse JSON for expected data
        // Expected JSON payload = { "reason": "PRODUCT_SAMPLING", "tracking": false, "tracking_endpoint": "trk.kissmetrics.com"}
        _success = YES;
        _expirationDate = [self kma_unixTimestampFromDateString:_expiresHeaderString];
        _doTrack = [[jsonDict objectForKey:@"tracking"] boolValue];
        _baseUrl = [NSString stringWithFormat:@"https://%@",(NSString*)[jsonDict objectForKey:@"tracking_endpoint"]];
    }
    
    if (self.delegate) {
        [self.delegate verificationSuccessful:_success doTrack:_doTrack baseUrl:_baseUrl expirationDate:_expirationDate];
    }
    
    // setDelegateQueue workaround ---- (3/4)
    CFRunLoopStop(CFRunLoopGetCurrent());
    // --------------------------------
}


// Rather than use the default cache policy, which may accept an Expires date beyond our failsafe limit, we ignore
// cached responses.
// We will honor the Expires header value ourselves while below the failsafe limit.
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}



# pragma mark - NSURLConnectionDelegate methods

// Sent when a connection fails to load its request successfully.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _connection = nil;
    _buffer = nil;
    
    if (self.delegate && error) {
        // We should always track by default. But we may not always send.
        [self.delegate verificationSuccessful:_success doTrack:_doTrack baseUrl:_baseUrl expirationDate:_expirationDate];
    }
    
    // setDelegateQueue workaround ---- (4/4)
    CFRunLoopStop(CFRunLoopGetCurrent());
    // --------------------------------
}


@end
