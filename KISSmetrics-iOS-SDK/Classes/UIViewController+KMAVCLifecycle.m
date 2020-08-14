//
// KISSmetricsSDK
//
// UIViewController+KMAVCLifecycle.m
//
// Picks up UIViewController lifecycle events:
// viewDidAppear and viewDidDisappear, then pass these events to the KM API.
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



#import <objc/runtime.h>
#import <objc/message.h>
#import "KMAMacros.c"
#import "KMASwizzler.h"
#import "UIViewController+KMAVCLifecycle.h"
#import "KISSmetricsAPI.h"
#import "KISSmetricsAPI_options.h"


@implementation UIViewController (KMAVCLifecycle)


static void kmac_viewDidAppear(id self, SEL _cmd, BOOL animated);
static void (*kmac_viewDidAppearIMP)(id self, SEL _cmd, BOOL animated);

static void kmac_viewDidDisappear(id self, SEL _cmd, BOOL animated);
static void (*kmac_viewDidDisappearIMP)(id self, SEL _cmd, BOOL animated);



// kmac_viewDidAppear
//
// Our swizzled viewDidAppear
//
// UIViewControllers are subclassed. If the customer has implemented -viewDidAppear:animated incorrectly by not calling
// the expected [super viewDidAppear:animated] the KM SDK framework will not be able to pick up this event. The customer
// likely does not have a good reason not to be calling super within this method.
static void kmac_viewDidAppear(UIViewController *self, SEL _cmd, BOOL animated)
{
    // We do not record the animated property. This is an option if we get enough requests for it.
    [[KISSmetricsAPI sharedAPI] record:[NSString stringWithFormat:@"%@ viewDidAppear", [self class]]];
    
    kmac_viewDidAppearIMP(self, _cmd, animated);
}



// kmac_viewDidDisappear
//
// Our swizzled viewDidDisappear
//
// UIViewControllers are subclassed. If the customer has implemented -viewDidDisappear:animated incorrectly by not calling
// the expected [super viewDidDisappear:animated] the KM SDK framework will not be able to pick up this event. The customer
// likely does not have a good reason not to be calling super within this method.
static void kmac_viewDidDisappear(id self, SEL _cmd, BOOL animated)
{
    // We do not record the animated property. This is an option if we get enough requests for it.
    [[KISSmetricsAPI sharedAPI] record:[NSString stringWithFormat:@"%@ viewDidDisappear", [self class]]];
    
    kmac_viewDidDisappearIMP(self, _cmd, animated);
}



+ (void)load
{
    // We only swizzle UIViewController lifecycle events if this
    // option has been selected in KISSmetricsAPI_options.m
    if (kKMARecordViewControllerLifecycles) {
        [self kmaSwizzle:@selector(viewDidAppear:) with:(IMP)kmac_viewDidAppear store:(IMP *)&kmac_viewDidAppearIMP];
        
        [self kmaSwizzle:@selector(viewDidDisappear:) with:(IMP)kmac_viewDidDisappear store:(IMP *)&kmac_viewDidDisappearIMP];
    }
}


@end
