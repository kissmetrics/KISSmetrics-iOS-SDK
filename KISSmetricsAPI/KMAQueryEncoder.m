//
// KISSmetricsSDK
//
// KMAQueryEncoder.m
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
#import "KMAQueryEncoder.h"

static NSString * const kKMAEventPath = @"/e";
static NSString * const kKMAPropPath  = @"/s";
static NSString * const kKMAAliasPath = @"/a";


@interface KMAQueryEncoder()
 @property (nonatomic, strong) NSString *_key;
 @property (nonatomic, strong) NSString *_clientType;
 @property (nonatomic, strong) NSString *_userAgent;
@end



@implementation KMAQueryEncoder


- (id)initWithKey:(NSString*)key
        clientType:(NSString*)clientType
        userAgent:(NSString*)userAgent
{
    self = [super init];
    
    if (self != nil) {
        self._key = key;
        self._clientType = clientType;
        self._userAgent = userAgent;
    }
    
    return self;
}



# pragma mark - Private methods

- (BOOL)_propertiesContainTimestamp:(NSDictionary*)properties
{
    if (properties && [properties objectForKey:@"_d"] && [properties objectForKey:@"_t"]) {
        return YES;
    }
    
    return NO;
}



# pragma mark - Public methods

- (NSString*)encodeQueryString:(NSString*)queryString
{
    NSString * encoded = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                   (CFStringRef)queryString, NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8 ));
    return encoded;
}


- (NSString*)encodeIdentity:(NSString*)identity {
    return [self encodeQueryString:identity];
}


- (NSString*)encodeEvent:(NSString*)event {
    return [self encodeQueryString:event];
}


- (NSString*)encodeProperties:(NSDictionary*)properties
{
    NSMutableString *propertiesUrlPart = [NSMutableString string];
    
    for (id propKey in [properties allKeys]) {
        
        if (![propKey isKindOfClass:[NSString class]]) {
            KMALog(@"KISSmetricsAPI - !WARNING! - property keys must be NSString. Dropping property.");
            continue;
        }
        
        NSString *stringKey = (NSString *)propKey;
        
        // Check for valid key
        if ([stringKey length] == 0) {
            KMALog(@"KISSmetricsAPI - !WARNING! - property keys must not be empty strings. Dropping property.");
            continue;
        }
        
        // Check for valid encoded key length.
        NSString *escapedKey = [self encodeQueryString:stringKey];
        if ([escapedKey length] > 255) {
            KMALog(@"KISSmetricsAPI - !WARNING! - property key cannot be longer than 255 characters. When URL escaped, your key is %li characters long (the submitted value is %@, the URL escaped value is %@). Dropping property.", (long)[escapedKey length], stringKey, escapedKey);
            continue;
        }
        
        // Check for valid value and value class type
        NSString *stringValue = nil;
        if ([properties objectForKey:stringKey] == nil) {
            KMALog(@"KISSmetricsAPI - !WARNING! - property value cannot be nil. Dropping property.");
            continue;
        }
        else if ([[properties objectForKey:stringKey] isKindOfClass:[NSString class]]) {
            stringValue = (NSString *)[properties objectForKey:stringKey];
        }
        else if ([[properties objectForKey:stringKey] isKindOfClass:[NSNumber class]]) {
            NSNumber *numberValue = (NSNumber *)[properties objectForKey:stringKey];
            stringValue = [numberValue stringValue];
        }
        
        // If it's not NSNumber or NSString, we drop it.
        if (stringValue == nil) {
            KMALog(@"KISSmetricsAPI - !WARNING! - property value cannot be of type %@. Dropping property.",
                   [[properties objectForKey:stringKey] class]);
            continue;
        }
        
        if ([stringValue length] == 0) {
            KMALog(@"KISSmetricsAPI - !WARNING! - property values must not be empty strings. Dropping property.");
            continue;
        }
        
        NSString *escapedValue = [self encodeQueryString:stringValue];
        
        [propertiesUrlPart appendFormat:@"&%@=%@", escapedKey, escapedValue];
    }
    
    return propertiesUrlPart;
}


- (NSString*)createEventQueryWithName:(NSString*)name
                          properties:(NSDictionary*)properties
                            identity:(NSString*)identity
                           timestamp:(NSInteger)timestamp
{
    NSMutableString *theUrl = [NSMutableString stringWithFormat:@"%@?_k=%@&_c=%@&_u=%@&_p=%@&_n=%@",
                                                                kKMAEventPath,
                                                                self._key,
                                                                self._clientType,
                                                                self._userAgent,
                                                                [self encodeIdentity:identity],
                                                                [self encodeEvent:name]];
    if (![self _propertiesContainTimestamp:properties]) {
        [theUrl appendFormat:@"&_d=1&_t=%li", (long)timestamp];
    }
    
    [theUrl appendString:[self encodeProperties:properties]];
    
    return theUrl;
}


- (NSString*)createPropertiesQueryWithProperties:(NSDictionary*)properties
                                        identity:(NSString*)identity
                                       timestamp:(NSInteger)timestamp
{
    NSMutableString *theUrl = [NSMutableString stringWithFormat:@"%@?_k=%@&_c=%@&_u=%@&_p=%@",
                                                                kKMAPropPath,
                                                                self._key,
                                                                self._clientType,
                                                                self._userAgent,
                                                                [self encodeIdentity:identity]];
    if (![self _propertiesContainTimestamp:properties]) {
        [theUrl appendFormat:@"&_d=1&_t=%li", (long)timestamp];
    }
    
    [theUrl appendString:[self encodeProperties:properties]];
    
    return theUrl;
}


- (NSString*)createAliasQueryWithAlias:(NSString*)alias
                           andIdentity:(NSString*)identity
{    
    NSString *theUrl = [NSString stringWithFormat:@"%@?_k=%@&_c=%@&_u=%@&_p=%@&_n=%@",
                                                  kKMAAliasPath,
                                                  self._key,
                                                  self._clientType,
                                                  self._userAgent,
                                                  [self encodeIdentity:alias],
                                                  [self encodeIdentity:identity]];
    return theUrl;
}


@end
