//  OCMockito by Jon Reid, https://qualitycoding.org/
//  Copyright 2020 Quality Coding, Inc. See LICENSE.txt

#import "MKTUnsignedCharReturnSetter.h"


@implementation MKTUnsignedCharReturnSetter

- (instancetype)initWithSuccessor:(nullable MKTReturnValueSetter *)successor
{
    self = [super initWithType:@encode(unsigned char) successor:successor];
    return self;
}

- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation
{
    unsigned char value = [returnValue unsignedCharValue];
    [invocation setReturnValue:&value];
}

@end
