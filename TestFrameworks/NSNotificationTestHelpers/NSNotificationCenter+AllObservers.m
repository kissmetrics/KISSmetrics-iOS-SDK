//
// KISSmetricsSDK_buildFiles_arc_impTests
//
// NSNotificationCenter+AllObservers.m
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



#import "NSNotificationCenter+AllObservers.h"

@implementation NSNotificationCenter (AllObservers)

const static void *namesKey = &namesKey;

+ (void) load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(addObserver:selector:name:object:)),
                                   class_getInstanceMethod(self, @selector(my_addObserver:selector:name:object:)));
}

- (void) my_addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString *)notificationName object:(id)notificationSender
{
    [self my_addObserver:notificationObserver selector:notificationSelector name:notificationName object:notificationSender];
    
    if (!notificationObserver || !notificationName)
        return;
    
    NSMutableDictionary *names = objc_getAssociatedObject(self, namesKey);
    if (!names)
    {
        names = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, namesKey, names, OBJC_ASSOCIATION_RETAIN);
    }
    
    NSMutableSet *observers = [names objectForKey:notificationName];
    if (!observers)
    {
        observers = [NSMutableSet setWithObject:notificationObserver];
        [names setObject:observers forKey:notificationName];
    }
    else
    {
        [observers addObject:notificationObserver];
    }
}

- (NSSet *) my_observersForNotificationName:(NSString *)notificationName
{
    NSMutableDictionary *names = objc_getAssociatedObject(self, namesKey);
    return [names objectForKey:notificationName] ?: [NSSet set];
}

@end
