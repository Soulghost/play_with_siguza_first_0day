//
//  SGIndexManager.h
//  codeSprite
//
//  Created by 11 on 12/19/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SGFileIndex;
@class SGClassIndex;
@class SGMethodIndex;

@interface SGIndexManager : NSObject

+ (instancetype)sharedManager;

- (NSArray<SGClassIndex *> *)indicesForClassNamed:(NSString *)className;
- (NSArray<SGFileIndex *> *)indicesForFileNamed:(NSString *)fileName;
- (NSArray<SGMethodIndex *> *)indicesForMethodKey:(NSString *)methodKey;

- (void)createIndexForPath:(NSString *)forPath toPath:(NSString *)toPath finish:(void (^)())finish;
- (void)loadSystemIndexWithCallback:(void (^)())finish;
- (void)loadUserIndexWithCallback:(void (^)())finish;
- (void)createUserIndex:(void (^)())finish;

@end
