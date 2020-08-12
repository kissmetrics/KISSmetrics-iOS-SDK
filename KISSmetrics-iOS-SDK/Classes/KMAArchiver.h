//
// KISSmetricsSDK
//
// KMAArchiver.h
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



#import <Foundation/Foundation.h>
#import "KISSmetricsAPI.h"

@interface KMAArchiver : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain, getter = keychainAppVersion, setter = setKeychainAppVersion:) NSString *keychainAppVersion;


+ (KMAArchiver *)sharedArchiverWithKey:(NSString *)apiKey;
+ (KMAArchiver *)sharedArchiver;

- (void)archiveInstallUuid:(NSString *)installUuid;
- (void)archiveDoTrack:(BOOL)doTrack;
- (void)archiveDoSend:(BOOL)doSend;
- (void)archiveBaseUrl:(NSString *)baseUrl;
- (void)archiveVerificationExpDate:(NSNumber *)expDate;
- (void)archiveHasGenericIdentity:(BOOL)hasGenericIdentity;
- (void)archiveFirstIdentity:(NSString*)firstIdentity;
- (void)archiveEvent:(NSString *)name withProperties:(NSDictionary *)properties onCondition:(KMARecordCondition)condition;
- (void)archiveProperties:(NSDictionary *)properties;
- (void)archiveDistinctProperty:(NSString *)property value:(NSObject *)value;
- (void)archiveIdentity:(NSString *)identity;
- (void)archiveAlias:(NSString *)firstIdentity withIdentity:(NSString *)secondIdentity;

- (void)clearSendQueue;
- (void)clearSavedIdEvents;
- (void)clearSavedProperties;
- (NSString *)getQueryStringAtIndex:(NSInteger)index;
- (void)removeQueryStringAtIndex:(NSInteger)index;
- (NSUInteger)getQueueCount;

- (NSString *)getInstallUuid;
- (NSNumber *)getVerificationExpDate;
- (NSString *)getBaseUrl;
- (NSString *)getIdentity;
- (BOOL)hasGenericIdentity;
- (BOOL)getDoSend;
- (BOOL)getDoTrack;


@end
