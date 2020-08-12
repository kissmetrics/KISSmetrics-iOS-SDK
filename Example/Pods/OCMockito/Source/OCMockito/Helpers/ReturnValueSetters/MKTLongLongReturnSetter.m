//  OCMockito by Jon Reid, https://qualitycoding.org/
//  Copyright 2020 Quality Coding, Inc. See LICENSE.txt

#import "MKTLongLongReturnSetter.h"


@implementation MKTLongLongReturnSetter

- (instancetype)initWithSuccessor:(nullable MKTReturnValueSetter *)successor
{
    self = [super initWithType:@encode(long long) successor:successor];
    return self;
}

- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation
{
    long long value = [returnValue longLongValue];
    [invocation setReturnValue:&value];
}

@end
