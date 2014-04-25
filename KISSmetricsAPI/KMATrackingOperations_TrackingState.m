//
// KISSmetricsSDK
//
// KMATrackingOperations_TrackingState.m
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



#import "KMATrackingOperations_TrackingState.h"
#import "KMAArchiver.h"
#import "KISSmetricsAPI.h"


// Obj-C doesn't have protected methods.
// This extension is used to expose the private kma_recursiveSend method.
@interface KISSmetricsAPI (KMAExposedRecursiveSend)
- (void)kma_recursiveSend;
@end


@implementation KMATrackingOperations_TrackingState


- (NSOperation *)identifyOperationWithIdentity:(NSString *)identity
                                      archiver:(KMAArchiver *)archiver
                                         kmapi:(KISSmetricsAPI *)kmapi {

    NSBlockOperation *opBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        // We need an autoreleasepool for operations run in a background thread.
        @autoreleasepool {
            [archiver archiveIdentity:identity];
            [kmapi kma_recursiveSend];
        }
    }];
    
    return opBlock;
}


- (NSOperation *)clearIdentityOperationWithNewIdentity:(NSString *)newIdentity
                                              archiver:(KMAArchiver *)archiver  {
    
    NSBlockOperation *opBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        @autoreleasepool {
            [archiver archiveFirstIdentity:newIdentity];
            [archiver clearSavedEvents];
            [archiver clearSavedProperties];
        }
    }];
    
    return opBlock;
}


- (NSOperation *)aliasOperationWithAlias:(NSString *)alias
                                identity:(NSString *)identity
                                archiver:(KMAArchiver *)archiver
                                   kmapi:(KISSmetricsAPI *)kmapi {
    
    NSBlockOperation *opBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        @autoreleasepool {
            [archiver archiveAlias:alias withIdentity:identity];
            [kmapi kma_recursiveSend];
        }
    }];
    
    return opBlock;
}


- (NSOperation *)recordOperationWithName:(NSString *)name
                              properties:(NSDictionary *)properties
                                archiver:(KMAArchiver *)archiver
                                   kmapi:(KISSmetricsAPI *)kmapi {
    
    NSBlockOperation *opBlock = [NSBlockOperation blockOperationWithBlock:^{

        @autoreleasepool {
            [archiver archiveEvent:name withProperties:properties];
            [kmapi kma_recursiveSend];
        }
    }];
    
    return opBlock;
}


- (NSOperation *)recordOnceOperationWithName:(NSString *)name
                                    archiver:(KMAArchiver *)archiver
                                       kmapi:(KISSmetricsAPI *)kmapi {
    
    NSBlockOperation *opBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        @autoreleasepool {
            [archiver archiveEventOnce:name];
            [kmapi kma_recursiveSend];
        }
    }];
    
    return opBlock;
}


- (NSOperation *)setOperationWithProperties:(NSDictionary *)properties
                                   archiver:(KMAArchiver *)archiver
                                      kmapi:(KISSmetricsAPI *)kmapi {
    
    NSBlockOperation *opBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        @autoreleasepool {
            [archiver archiveProperties:properties];
            [kmapi kma_recursiveSend];
        }
    }];
    
    return opBlock;
}


- (NSOperation *)setDistinctOperationWithPropertyValue:(NSObject *)propertyValue
                                                forKey:(NSString *)propertyKey
                                              archiver:(KMAArchiver *)archiver
                                                 kmapi:(KISSmetricsAPI *)kmapi {
    
    NSBlockOperation *opBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        @autoreleasepool {
            [archiver archiveDistinctProperty:propertyKey value:propertyValue];
            [kmapi kma_recursiveSend];
        }
    }];
    
    return opBlock;
}


@end
