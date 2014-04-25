//
// KISSmetricsSDK
//
// KMATrackingOperations_NonTrackingState.m
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



#import "KMATrackingOperations_NonTrackingState.h"
#import "KMAArchiver.h"
#import "KISSmetricsAPI.h"

@implementation KMATrackingOperations_NonTrackingState


- (NSOperation *)identifyOperationWithIdentity:(NSString *)identity
                                      archiver:(KMAArchiver *)archiver
                                         kmapi:(KISSmetricsAPI *)kmap {
    return nil;
}


- (NSOperation *)clearIdentityOperationWithNewIdentity:(NSString *)newIdentity
                                              archiver:(KMAArchiver *)archiver {
    return nil;
}


- (NSOperation *)aliasOperationWithAlias:(NSString *)alias
                                identity:(NSString *)identity
                                archiver:(KMAArchiver *)archiver
                                   kmapi:(KISSmetricsAPI *)kmapi {
    return nil;
}


- (NSOperation *)recordOperationWithName:(NSString *)name
                              properties:(NSDictionary *)properties
                                archiver:(KMAArchiver *)archiver
                                   kmapi:(KISSmetricsAPI *)kmapi {
    return nil;
}


- (NSOperation *)recordOnceOperationWithName:(NSString *)name
                                    archiver:(KMAArchiver *)archiver
                                       kmapi:(KISSmetricsAPI *)kmapi {
    return nil;
}


- (NSOperation *)setOperationWithProperties:(NSDictionary *)properties
                                   archiver:(KMAArchiver *)archiver
                                      kmapi:(KISSmetricsAPI *)kmapi {
    return nil;
}


- (NSOperation *)setDistinctOperationWithPropertyValue:(NSObject *)propertyValue
                                                forKey:(NSString *)propertyKey
                                              archiver:(KMAArchiver *)archiver
                                                 kmapi:(KISSmetricsAPI *)kmapi {
    return nil;
}


@end
