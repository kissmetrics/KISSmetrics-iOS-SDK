//
// KISSmetricsSDK
//
// KMASendingOperations_NonSendingState.m
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



#import "KMASendingOperations_NonSendingState.h"
#import "KMAArchiver.h"
#import "KMAConnection.h"

@implementation KMASendingOperations_NonSendingState

// Returns nil as no sending operation should be run in a non-sending state.
- (NSOperation *)recursiveSendOperationWithArchiver:(KMAArchiver *)archiver
                                         connection:(KMAConnection *)connection
                                 connectionDelegate:(id <KMAConnectionDelegate>)connectionDelegate {
    return nil;
}


@end