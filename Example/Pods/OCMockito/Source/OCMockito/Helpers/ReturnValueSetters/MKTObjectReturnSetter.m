//  OCMockito by Jon Reid, https://qualitycoding.org/
//  Copyright 2020 Quality Coding, Inc. See LICENSE.txt

#import "MKTObjectReturnSetter.h"


@implementation MKTObjectReturnSetter

- (instancetype)initWithSuccessor:(nullable MKTReturnValueSetter *)successor
{
    self = [super initWithType:@encode(id) successor:successor];
    return self;
}

- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation
{
    __unsafe_unretained id value = returnValue;
    [invocation setReturnValue:&value];
}

@end
