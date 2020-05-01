//
//  SGIndexStorage.m
//  codeSprite
//
//  Created by soulghost on 29/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGIndexStorage.h"

NSString * const kClassIndices = @"SGClassIndices";
NSString * const kFileIndices = @"SGFileIndices";
NSString * const kMethodIndices = @"SGMethodIndices";

@implementation SGIndexStorage

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.classIndices forKey:kClassIndices];
    [encoder encodeObject:self.fileIndices forKey:kFileIndices];
    [encoder encodeObject:self.methodIndices forKey:kMethodIndices];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.classIndices = [decoder decodeObjectForKey:kClassIndices];
        self.fileIndices = [decoder decodeObjectForKey:kFileIndices];
        self.methodIndices = [decoder decodeObjectForKey:kMethodIndices];
    }
    return self;
}

#pragma mark 索引添加
- (void)addClassIndex:(SGClassIndex *)classIndex {
    NSString *className = classIndex.className;
    if (!className) return;
    if (![[self.classIndices allKeys] containsObject:className]) {
        self.classIndices[className] = classIndex;
    }
}

- (void)addMethodIndex:(SGMethodIndex *)methodIndex {
    NSString *methodKey = methodIndex.methodKey;
    if (!methodKey) return;
    if ([[self.methodIndices allKeys] containsObject:methodKey]) {
        NSMutableArray *indices = self.methodIndices[methodKey];
        [indices addObject:methodIndex];
    } else {
        self.methodIndices[methodKey] = @[methodIndex].mutableCopy;
    }
}

- (void)addFileIndex:(SGFileIndex *)fileIndex {
    NSString *commonName = fileIndex.commonName;
    if (!commonName) return;
    if ([[self.fileIndices allKeys] containsObject:commonName]) {
        NSMutableArray *indices = self.fileIndices[commonName];
        [indices addObject:fileIndex];
    } else {
        self.fileIndices[commonName] = @[fileIndex].mutableCopy;
    }
}

#pragma mark 懒加载
- (NSMutableDictionary<NSString *,SGClassIndex *> *)classIndices {
    if (_classIndices == nil) {
        _classIndices = @{}.mutableCopy;
    }
    return _classIndices;
}

- (NSMutableDictionary<NSString *,NSMutableArray<SGFileIndex *> *> *)fileIndices {
    if (_fileIndices == nil) {
        _fileIndices = @{}.mutableCopy;
    }
    return _fileIndices;
}

- (NSMutableDictionary<NSString *,NSMutableArray<SGMethodIndex *> *> *)methodIndices {
    if (_methodIndices == nil) {
        _methodIndices = @{}.mutableCopy;
    }
    return _methodIndices;
}

@end
