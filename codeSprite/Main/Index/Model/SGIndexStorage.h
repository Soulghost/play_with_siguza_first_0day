//
//  SGIndexStorage.h
//  codeSprite
//
//  Created by soulghost on 29/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGIndexStorage : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableDictionary<NSString *, SGClassIndex *> *classIndices;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<SGFileIndex *> *> *fileIndices;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<SGMethodIndex *> *> *methodIndices;

- (void)addClassIndex:(SGClassIndex *)classIndex;
- (void)addMethodIndex:(SGMethodIndex *)methodIndex;
- (void)addFileIndex:(SGFileIndex *)fileIndex;

@end
