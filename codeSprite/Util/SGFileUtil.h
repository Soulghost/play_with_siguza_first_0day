//
//  SGFileUtil.h
//  codeSprite
//
//  Created by soulghost on 27/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGFileUtil : NSObject

+ (instancetype)sharedUtil;
+ (NSString *)commonNameForFileNamed:(NSString *)fileName;
+ (NSString *)extensionNameForFileNamed:(NSString *)fileName;
+ (NSString *)rootPath;
+ (NSString *)sysLibPath;
+ (NSString *)indexPath;
+ (NSString *)relativePathFromPath:(NSString *)path;

- (BOOL)isValidCodeFileNamed:(NSString *)fileName;
- (BOOL)isValidPreviewFileNamed:(NSString *)fileName;
- (void)previewFile:(NSString *)filePath forViewController:(UIViewController *)viewController;

@end
