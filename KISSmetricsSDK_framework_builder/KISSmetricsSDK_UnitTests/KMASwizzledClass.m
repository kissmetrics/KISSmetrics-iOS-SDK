//
// KISSmetricsSDK - Unit Tests
//
// KMASwizzledClass.m
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



#import "KMASwizzledClass.h"


@implementation ClassToBeSwizzled
- (void)someInstanceMethodWithCompletion:(void (^)(NSString*))callbackBlock
{
    callbackBlock(@"original");
}
+ (void)someClassMethodWithCompletion:(void (^)(NSString*))callbackBlock
{
    callbackBlock(@"original");
}
@end



// Category doing the swizzling
@implementation ClassToBeSwizzled (Swizz)

static void KMASomeInstanceMethodWithCompletion(id self, SEL _cmd, void (^callbackBlock)(NSString*));
static void (*SomeInstanceMethodWithCompletionIMP)(id self, SEL _cmd, void (^callbackBlock)(NSString*) );

static void KMASomeInstanceMethodWithCompletion(UIViewController *self, SEL _cmd, void (^callbackBlock)(NSString*))
{
    callbackBlock(@"swizzled");
    SomeInstanceMethodWithCompletionIMP(self, _cmd, callbackBlock);
}

static void KMASomeClassMethodWithCompletion(id self, SEL _cmd, void (^callbackBlock)(NSString*));
static void (*SomeClassMethodWithCompletionIMP)(id self, SEL _cmd, void (^callbackBlock)(NSString*) );

static void KMASomeClassMethodWithCompletion(UIViewController *self, SEL _cmd, void (^callbackBlock)(NSString*))
{
    callbackBlock(@"swizzled");
    SomeClassMethodWithCompletionIMP(self, _cmd, callbackBlock);
}

+ (void)load
{
    [self kmaSwizzle:@selector(someInstanceMethodWithCompletion:) with:(IMP)KMASomeInstanceMethodWithCompletion store:(IMP *)&SomeInstanceMethodWithCompletionIMP];
    [self kmaSwizzleClassMethod:@selector(someClassMethodWithCompletion:) with:(IMP)KMASomeClassMethodWithCompletion store:(IMP *)&SomeClassMethodWithCompletionIMP];
}

@end

