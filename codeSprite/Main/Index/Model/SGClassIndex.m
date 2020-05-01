//
//  SGClassIndex.m
//  codeSprite
//
//  Created by soulghost on 26/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGClassIndex.h"

NSString *const kClassName = @"SGClassIndexClassName";

@implementation SGClassIndex

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.className forKey:kClassName];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.className = [decoder decodeObjectForKey:kClassName];
    }
    return self;
}

@end
