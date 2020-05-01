//
//  SGMethodIndex.m
//  codeSprite
//
//  Created by soulghost on 28/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGMethodIndex.h"

NSString * kMethodKey = @"SGMethodIndexMethodKeyKey";
NSString * kMethodName = @"SGMethodIndexMethodNameKey";

@implementation SGMethodIndex

- (void)setMethodKey:(NSString *)methodKey {
    _methodKey = methodKey;
    NSArray *parts = [methodKey componentsSeparatedByString:@":"];
    NSMutableString *methodName = @"".mutableCopy;
    if (parts.count) {
        NSString *front = [parts firstObject];
        [methodName appendString:front];
        NSInteger count = parts.count - 1;
        while (count--) {
            [methodName appendString:@":"];
        }
    }
    _methodName = [methodName copy];;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.methodKey forKey:kMethodKey];
    [encoder encodeObject:self.methodName forKey:kMethodName];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.methodKey = [decoder decodeObjectForKey:kMethodKey];
        _methodName = [decoder decodeObjectForKey:kMethodName];
    }
    return self;
}

@end
