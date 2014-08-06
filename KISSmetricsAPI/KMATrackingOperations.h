//
// KISSmetricsSDK
//
// KMATrackingOperations.h
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
@class KMAArchiver;


@protocol KMATrackingOperations <NSObject>

@required

- (NSOperation *)identifyOperationWithIdentity:(NSString *)identity
                                      archiver:(KMAArchiver *)archiver
                                         kmapi:(KISSmetricsAPI *)kmapi;

- (NSOperation *)clearIdentityOperationWithNewIdentity:(NSString *)newIdentity
                                              archiver:(KMAArchiver *)archiver;

- (NSOperation *)aliasOperationWithAlias:(NSString *)alias
                                identity:(NSString *)identity
                                archiver:(KMAArchiver *)archiver
                                   kmapi:(KISSmetricsAPI *)kmapi;

- (NSOperation *)recordOperationWithName:(NSString *)name
                              properties:(NSDictionary *)properties
                               condition:(KMARecordCondition)condition
                                archiver:(KMAArchiver *)archiver
                                   kmapi:(KISSmetricsAPI *)kmapi;

- (NSOperation *)setOperationWithProperties:(NSDictionary *)properties
                                   archiver:(KMAArchiver *)archiver
                                      kmapi:(KISSmetricsAPI *)kmapi;

- (NSOperation *)setDistinctOperationWithPropertyValue:(NSObject *)propertyValue
                                                forKey:(NSString *)propertyKey
                                              archiver:(KMAArchiver *)archiver
                                                 kmapi:(KISSmetricsAPI *)kmapi;

@end
