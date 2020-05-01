//
//  SGFileUtil.m
//  codeSprite
//
//  Created by soulghost on 27/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGFileUtil.h"
#import <QuickLook/QuickLook.h>

@interface SGFileUtil () <QLPreviewControllerDataSource>

@property (nonatomic, strong) NSDictionary *codeFileSuffixMap;
@property (nonatomic, strong) NSDictionary *previewFileMap;
@property (nonatomic, copy) NSString *filePathToPreview;


@end

@implementation SGFileUtil

+ (instancetype)sharedUtil {
    static SGFileUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

+ (NSString *)commonNameForFileNamed:(NSString *)fileName {
    NSArray *fileParts = [fileName componentsSeparatedByString:@"."];
    if (fileParts.count == 2) {
        return [fileParts firstObject];
    } else {
        NSMutableString *tmp = @"".mutableCopy;
        for (NSUInteger i = 0; i < fileParts.count - 1; i++) {
            [tmp appendString:fileParts[i]];
        }
        return tmp;
    }
}

+ (NSString *)extensionNameForFileNamed:(NSString *)fileName {
    NSArray *parts = [fileName componentsSeparatedByString:@"."];
    if (parts.count >= 2) {
        return [parts lastObject];
    } else {
        return @"";
    }
}

+ (NSString *)rootPath {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"codeSprite"];
    NSFileManager *mgr = [NSFileManager defaultManager];
    if(![mgr fileExistsAtPath:path]){
        NSError *err;
        [mgr createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&err];
    }
    return path;
}

+ (NSString *)sysLibPath {
    NSString *rootPath = self.rootPath;
    return [rootPath stringByAppendingPathComponent:@".sysLib"];
}

+ (NSString *)indexPath {
    NSString *rootPath = self.rootPath;
    NSString *indexPath = [rootPath stringByAppendingPathComponent:@".index"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:indexPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:indexPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return indexPath;
}

+ (NSString *)relativePathFromPath:(NSString *)path {
    NSRange range = [path rangeOfString:@"/Library/Caches/codeSprite/"];
    if (range.location != NSNotFound) {
        NSInteger location = range.location + range.length;
        if (path.length > location) {
            return [path substringFromIndex:location];
        }
    }
    return [self rootPath];
}

- (BOOL)isValidCodeFileNamed:(NSString *)fileName {
    NSString *extensionName = [SGFileUtil extensionNameForFileNamed:fileName];
    return [[self.codeFileSuffixMap allKeys] containsObject:extensionName];
}

- (BOOL)isValidPreviewFileNamed:(NSString *)fileName {
    NSString *extensionName = [SGFileUtil extensionNameForFileNamed:fileName];
    return self.previewFileMap[extensionName] != nil;
}

- (void)previewFile:(NSString *)filePath forViewController:(UIViewController *)viewController{
    QLPreviewController *previewVc = [[QLPreviewController alloc] init];
    previewVc.dataSource = self;
    self.filePathToPreview = filePath;
    [viewController presentViewController:previewVc animated:YES completion:nil];
}

#pragma mark 懒加载
- (NSDictionary *)codeFileSuffixMap {
    if (_codeFileSuffixMap == nil) {
        NSMutableDictionary *tmpMap = @{}.mutableCopy;
        NSArray *validSuffix = @[@"m",@"h",@"mm",@"c",@"cpp",@"cs",@"php",@"java",@"py"];
        for (NSUInteger i = 0; i < validSuffix.count; i++) {
            tmpMap[validSuffix[i]] = [NSObject new];
        }
        _codeFileSuffixMap = tmpMap;
    }
    return _codeFileSuffixMap;
}

/*
 iWork documents
 Microsoft Office documents (Office ‘97 and newer)
 Rich Text Format (RTF) documents
 PDF files
 Images
 Text files whose uniform type identifier (UTI) conforms to the public.text type (see Uniform Type Identifiers Reference)
 Comma-separated value (csv) files
 */
- (NSDictionary *)previewFileMap {
    if (_previewFileMap == nil) {
        NSMutableDictionary *tmpMap = @{}.mutableCopy;
        NSArray *validFile = @[@"doc",@"docx",@"ppt",@"xls",@"rtf",@"pdf",@"png",@"jpg",@"jpeg",@"gif",@"csv"];
        for (NSUInteger i = 0; i < validFile.count; i++) {
            tmpMap[validFile[i]] = [NSObject new];
        }
        _previewFileMap = tmpMap;
    }
    return _previewFileMap;
}

#pragma mark QLPreviewController Delegate
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:self.filePathToPreview];
}

@end
