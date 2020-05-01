//
//  SGIndex.m
//  codeSprite
//
//  Created by soulghost on 27/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGIndex.h"

NSString * const kFilePath = @"SGIndexFilePath";
NSString * const kFileName = @"SGIndexFileName";
NSString * const kRange = @"SGIndexRange";

@implementation SGIndex

@synthesize filePath = _filePath;

- (void)setFilePath:(NSString *)filePath{
    _filePath = filePath;
    _fileName = [[filePath componentsSeparatedByString:@"/"] lastObject];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.fileName forKey:kFileName];
    // 不要使用get方法获取，否则得到的是绝对路径，应该保存相对路径
    [encoder encodeObject:_filePath forKey:kFilePath];
    [encoder encodeObject:[NSValue valueWithRange:self.range] forKey:kRange];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.filePath = [decoder decodeObjectForKey:kFilePath];
        self.fileName = [decoder decodeObjectForKey:kFileName];
        self.range = [[decoder decodeObjectForKey:kRange] rangeValue];
    }
    return self;
}

- (NSString *)filePath {
    return [[SGFileUtil rootPath] stringByAppendingPathComponent:_filePath];
}

@end
