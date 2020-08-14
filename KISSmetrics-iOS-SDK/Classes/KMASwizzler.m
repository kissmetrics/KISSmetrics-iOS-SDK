//
// KISSmetricsSDK
//
// KMASwizzler.m
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
#import "KMASwizzler.h"

BOOL kma_class_swizzleMethodAndStore(Class class, SEL original, IMP replacement, KMAIMPPointer store);
BOOL kma_class_swizzleMethodAndStore(Class class, SEL original, IMP replacement, KMAIMPPointer store) {
	BOOL success = FALSE;
	IMP imp = NULL;
	Method method = class_getInstanceMethod(class, original);
	if (method) {
		// Ensure the method is defined in this class by trying to add it to the class, get the new method
		// pointer if it was actually added (this is now considered the original), then get the imp for the
		// original method & replace the method.
		const char *type = method_getTypeEncoding(method);
		if (class_addMethod(class, original, method_getImplementation(method), type)) {
			method = class_getInstanceMethod(class, original);
		}
		imp = method_getImplementation(method);
		success = TRUE;
		class_replaceMethod(class, original, replacement, type);
	}
	if (imp && store) { *store = imp; }
	return success;
}


@implementation NSObject (KMASwizzler)

+ (BOOL)kmaSwizzle:(SEL)original with:(IMP)replacement store:(KMAIMPPointer)store {
	return kma_class_swizzleMethodAndStore(self, original, replacement, store);
}

+ (BOOL)kmaSwizzleClassMethod:(SEL)original with:(IMP)replacement store:(KMAIMPPointer)store {
	return kma_class_swizzleMethodAndStore(object_getClass(self), original, replacement, store);
}


@end