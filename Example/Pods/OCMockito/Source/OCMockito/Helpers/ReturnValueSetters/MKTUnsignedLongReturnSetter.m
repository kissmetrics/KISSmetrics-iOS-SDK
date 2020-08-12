//  OCMockito by Jon Reid, https://qualitycoding.org/
//  Copyright 2020 Quality Coding, Inc. See LICENSE.txt

#import "MKTUnsignedLongReturnSetter.h"


@implementation MKTUnsignedLongReturnSetter

- (instancetype)initWithSuccessor:(nullable MKTReturnValueSetter *)successor
{
    self = [super initWithType:@encode(unsigned long) successor:successor];
    return self;
}

- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation
{
    unsigned long value = [returnValue unsignedLongValue];
    [invocation setReturnValue:&value];
}

@end
