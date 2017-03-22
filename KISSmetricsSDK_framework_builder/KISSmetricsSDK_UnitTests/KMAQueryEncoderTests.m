//
// KISSmetricsSDK - Unit Tests
//
// KMAQueryEncoderTests.m
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



// Class under test
#import "KMAQueryEncoder.h"

// Test support
#import <XCTest/XCTest.h>


@interface KMAQueryEncoderTests : XCTestCase
@end

@implementation KMAQueryEncoderTests
{
    KMAQueryEncoder *_queryEncoder;
    
    // Test fixture ivars
    NSString *_reservedString;
    NSString *_encodedReservedString;
    NSString *_unsafeString;
    NSString *_encodedUnsafeString;
    NSString *_unreservedString;
    NSString *_encodedUnreservedString;
    NSString *_key;
    NSString *_clientType;
    NSString *_userAgent;
}

- (void)setUp {
    
    [super setUp];
    
    NSLog(@"KMAArchiverTests setUp");
    
    _key = @"b8f68fe5004d29bcd21d3138b43ae755a16c12cf";
    _clientType  = @"mobile_app";
    _userAgent   = @"kissmetrics-ios/2.3.1";
    
    _queryEncoder = [[KMAQueryEncoder alloc] initWithKey:_key
                                              clientType:_clientType
                                               userAgent:_userAgent];
    //http://tools.ietf.org/html/rfc3986
    _reservedString = @"!*'();:@&=+$,/?#[]";
    _encodedReservedString = @"%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%23%5B%5D";
    _unsafeString = @"<>#%{}|\\^~` []";
    _encodedUnsafeString = @"%3C%3E%23%25%7B%7D%7C%5C%5E~%60%20%5B%5D";
    _unreservedString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
    _encodedUnreservedString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";

}


- (void)test_urlEncodeOfReservedCharacters {

    NSString *encodedString = [_queryEncoder encodeQueryString:_reservedString];
    
    XCTAssertEqualObjects(encodedString, _encodedReservedString, @"Encoded string not as expected");
}


- (void)test_urlEncodeOfUnsafeCharacters {
    
    NSString *encodedString = [_queryEncoder encodeQueryString:_unsafeString];
    
    XCTAssertEqualObjects(encodedString, _encodedUnsafeString, @"Encoded string not as expected");
}


- (void)test_urlEncodeOfUnreservedCharacters {
    
    NSString *encodedString = [_queryEncoder encodeQueryString:_unreservedString];
    
    XCTAssertEqualObjects(encodedString, _encodedUnreservedString, @"Encoded string not as expected");
}


- (void)test_urlEncodeIdentity {
    
    NSString *testIdentityString = @"testuser@example.com";
    
    // For now we expect identities to have basic url encoding, so we only test for a match from _urlEncode.
    NSString *expectedEncodedIdentity = [_queryEncoder encodeQueryString:testIdentityString];

    NSString *encodedIdentity = [_queryEncoder encodeIdentity:testIdentityString];
    
    XCTAssertEqualObjects(encodedIdentity, expectedEncodedIdentity, @"Encoded string not as expected");
}


- (void)test_urlEncodeEvent {
    
    NSString *testEventString = @"KISSMetrics urlEncodeEvent";
    
    // For now we expect events to have basic url encoding, so we only test for a match from _urlEncode.
    NSString *expectedEncodedEvent = [_queryEncoder encodeQueryString:testEventString];
    
    NSString *encodedEvent = [_queryEncoder encodeEvent:testEventString];
    
    XCTAssertEqualObjects(encodedEvent, expectedEncodedEvent, @"Encoded string not as expected");
}


- (void)test_urlEncodeProperties {
    
    NSDictionary *testPropertyDictionary = @{@"Reserved": _reservedString,
                                             @"Unsafe": _unsafeString,
                                             @"Unreserved": _unreservedString};
    
    NSString *encodedProperties = [_queryEncoder encodeProperties:testPropertyDictionary];
    
    // NSDictionary iteration does not guarantee order.
    // We can only reliably check that our encoded string contains the 3 expected properties.
    encodedProperties = [encodedProperties stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&Reserved=%@",   _encodedReservedString]   withString:@""];
    encodedProperties = [encodedProperties stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&Unsafe=%@",     _encodedUnsafeString]     withString:@""];
    encodedProperties = [encodedProperties stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&Unreserved=%@", _encodedUnreservedString] withString:@""];
    
    NSString *expectedEncodedProperties = @"";
    
    XCTAssertEqualObjects(encodedProperties, expectedEncodedProperties, @"Encoded string not as expected");
}



#pragma mark - test private URL creation methods

- (void)test_createUrlForEventAndProperties {

    int timestamp = [[NSDate date] timeIntervalSince1970];

    NSString *createdUrl = [_queryEncoder createEventQueryWithName:@"testEvent"
                                                        properties:@{@"propertyOne" : @"testPropertyOne",
                                                                     @"propertyTwo" : @"testPropertyTwo"}
                                                          identity:@"testuser@example.com"
                                                         timestamp:timestamp];
    
    NSString *expectedUrl = @"/e?_k=b8f68fe5004d29bcd21d3138b43ae755a16c12cf&_c=mobile_app&_u=kissmetrics-ios/2.3.1&_p=testuser%40example.com";
    expectedUrl = [expectedUrl stringByAppendingString:[NSString stringWithFormat:@"&_n=testEvent&_d=1&_t=%i&propertyOne=testPropertyOne&propertyTwo=testPropertyTwo", timestamp]];

    XCTAssertEqualObjects(createdUrl, expectedUrl, @"URL incorrect");
}


- (void)test_createUrlForProperties {
    
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *createdUrl = [_queryEncoder createPropertiesQueryWithProperties:@{@"propertyOne" : @"testPropertyOne",
                                                                                @"propertyTwo" : @"testPropertyTwo"}
                                                                     identity:@"testuser@example.com"
                                                                    timestamp:timestamp];
    
    NSString *expectedUrl = @"/s?_k=b8f68fe5004d29bcd21d3138b43ae755a16c12cf&_c=mobile_app&_u=kissmetrics-ios/2.3.1&_p=testuser%40example.com&_d=1&_t=";
    
    expectedUrl = [expectedUrl stringByAppendingString:[NSString stringWithFormat:@"%i", timestamp]];
    expectedUrl = [expectedUrl stringByAppendingString:@"&propertyOne=testPropertyOne&propertyTwo=testPropertyTwo"];

    XCTAssertEqualObjects(createdUrl, expectedUrl, @"URL incorrect");
}


- (void)test_createUrlForIdentity {

    NSString *createdUrl = [_queryEncoder createAliasQueryWithAlias:@"testnewuser@example.com" andIdentity:@"testolduser@example.com"];
    
    NSString *expectedUrl = @"/a?_k=b8f68fe5004d29bcd21d3138b43ae755a16c12cf&_c=mobile_app&_u=kissmetrics-ios/2.3.1&_p=testnewuser%40example.com&_n=testolduser%40example.com";
    
    XCTAssertEqualObjects(createdUrl, expectedUrl, @"URL incorrect");
}


@end
