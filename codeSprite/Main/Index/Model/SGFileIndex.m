//
//  SGFileIndex.m
//  codeSprite
//
//  Created by soulghost on 27/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGFileIndex.h"

NSString * const kCommonName = @"SGFileIndexCommonName";

@implementation SGFileIndex

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.commonName forKey:kCommonName];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.commonName = [decoder decodeObjectForKey:kCommonName];
    }
    return self;
}

@end
