//
//  SGIndexManager.m
//  codeSprite
//
//  Created by 11 on 12/19/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import "SGIndexManager.h"
#import "RegexKitLite.h"
#import "SGClassIndex.h"
#import "SSZipArchive.h"

NSString * const systemIndexName = @"system.index";
NSString * const userIndexName = @"user.index";

@interface SGIndexManager ()

@property (nonatomic, strong) SGIndexStorage *sysStorage;
@property (nonatomic, strong) SGIndexStorage *userStorage;
@property (nonatomic, assign) BOOL isUserStorage;

@end

@implementation SGIndexManager

+ (instancetype)sharedManager{
    static SGIndexManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SGIndexManager alloc] init];
    });
    return instance;
}

- (BOOL)checkCodeFile:(NSString *)fileName {
    NSArray *validSuffix = @[@".m",@".h",@".mm",@".c",@".cpp",@".php",@".java",@".py"];
    NSInteger cnt = validSuffix.count;
    for (NSInteger i = 0; i < cnt; i++) {
        if ([fileName hasSuffix:validSuffix[i]]) {
            return YES;
        }
    }
    return NO;
}

- (void)searchFiles:(NSString *)path {
    if (self.isUserStorage) {
        NSArray *comps = [path componentsSeparatedByString:@"/"];
        if (comps.count) {
            NSString *fileName = [comps lastObject];
            if ([fileName hasPrefix:@"."]) {
                return;
            }
        }
    }
    BOOL isDir;
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr fileExistsAtPath:path isDirectory:&isDir];
    if (isDir) {
        NSArray *pathes = [mgr contentsOfDirectoryAtPath:path error:nil];
        for(NSString *ph in pathes){
            if ([ph isEqualToString:@"__MACOSX"] || [ph hasPrefix:@"."]) {
                continue;
            }
            [self searchFiles:[path stringByAppendingPathComponent:ph]];
        }
    }else{
        if([self checkCodeFile:path]){
            [self parseFile:path];
            [self addFileIndexForFileInPath:path];
        }
    }
}

- (void)parseFile:(NSString*)path {
//    NSLog(@"parse file %@",path);
    NSData *codeData = [NSData dataWithContentsOfFile:path];
    NSArray<NSString*> *pathComps = [path componentsSeparatedByString:@"/"];
    NSString *fileName = pathComps[pathComps.count - 1];
    NSString *code = [[NSString alloc] initWithData:codeData encoding:NSUTF8StringEncoding];
    NSString *relativePath = [SGFileUtil relativePathFromPath:path];
    // 类索引器
    [code enumerateStringsMatchedByRegex:@"@interface.*:.*" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString *capStr = *capturedStrings;
        if (capStr.length < 12) return;
        NSMutableString *className = @"".mutableCopy;
        for (NSUInteger i = 11; i < capStr.length; i++) {
            char c = [capStr characterAtIndex:i];
            if (c == '<' || c == ' ') {
                break;
            }
            [className appendFormat:@"%c",c];
        }
        @autoreleasepool {
            SGClassIndex *index = [SGClassIndex new];
            index.filePath = relativePath;
            index.fileName = fileName;
            index.className = className;
            index.range = *capturedRanges;
//            if (![[self.storage.classIndices allKeys] containsObject:className]) {
//                self.storage.classIndices[className] = index;
//            }
            if (self.isUserStorage) {
                [self.userStorage addClassIndex:index];
            } else {
                [self.sysStorage addClassIndex:index];
            }
        }
    }];
    // 结构体索引器
    [code enumerateStringsMatchedByRegex:@"struct.*\\{|typedef struct.*" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString *capStr = *capturedStrings;
        NSString *structName = nil;
        if ([capStr hasPrefix:@"typedef"]) {
            NSArray *parts = [capStr componentsSeparatedByString:@" "];
            if (parts.count) {
                NSString *last = [parts lastObject];
                if (last.length > 1) {
                    if ([last characterAtIndex:0] == '*' && last.length > 2) {
                        structName = [last substringWithRange:NSMakeRange(1, last.length - 2)];
                    } else {
                        structName = [last substringToIndex:last.length - 1];
                    }
                }
            }
        } else {
            NSArray *parts = [capStr componentsSeparatedByString:@" "];
            if (parts.count == 3) {
                structName = parts[1];
            }
        }
        if (structName) {
            @autoreleasepool {
                SGClassIndex *index = [SGClassIndex new];
                index.className = structName;
                index.filePath = relativePath;
                index.fileName = fileName;
                index.range = *capturedRanges;
//                if (![[self.storage.classIndices allKeys] containsObject:structName]) {
//                    self.storage.classIndices[structName] = index;
//                }
                if (self.isUserStorage) {
                    [self.userStorage addClassIndex:index];
                } else {
                    [self.sysStorage addClassIndex:index];
                }
            }
        }
    }];
    // 方法索引器
    [code enumerateStringsMatchedByRegex:@"[-+]\\s*\\(.*\\).*\\s*[;\\{]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
//        NSLog(@"method:\n%@",*capturedStrings);
        NSString *capStr = *capturedStrings;
        // 方法的组成部分
        // -/+ (void)comp1:(xxx)xxx comp2:(xxx)xxx
        // 1.首先找到第一个右括号，其后即为方法名起点
        NSInteger cur = [capStr rangeOfString:@")"].location + 1;
        for (; cur < capStr.length; cur++) {
            if (isalpha([capStr characterAtIndex:cur])) {
                break;
            }
        }
        if (cur < capStr.length) {
            NSString *methodStr = [capStr substringFromIndex:cur];
//            NSLog(@"%@",methodStr);
            NSArray *parts = [methodStr componentsSeparatedByString:@" "];
            NSMutableString *methodKey = @"".mutableCopy;
            for (NSUInteger i = 0; i < parts.count; i++) {
                NSString *partStr = parts[i];
                if (partStr.length && isalpha([partStr characterAtIndex:0])) {
                    NSInteger end = [partStr rangeOfString:@":"].location;
                    if (end == NSNotFound) { // no param method
                        if (!methodKey.length) { // to avoid "initWithFrame:NS_DESIGNATED_INITIALIZER" like method
                            [methodKey appendString:partStr];
                        }
                    } else { // param method
                        NSString *methodComp = [partStr substringToIndex:end + 1];
                        [methodKey appendString:methodComp];
                    }
                }
            }
            /*
                initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
                2016-04-29 00:20:55.576 codeSprite[5969:411444] method Key = <initWithFrame:NS_DESIGNATED_INITIALIZER;>
             */
//            NSLog(@"method Key = <%@>",methodKey);
            @autoreleasepool {
                SGMethodIndex *index = [SGMethodIndex new];
                index.methodKey = methodKey;
                index.range = *capturedRanges;
                index.fileName = fileName;
                index.filePath = relativePath;
//                if ([[self.storage.methodIndices allKeys] containsObject:methodKey]) {
//                    NSMutableArray *indices = self.storage.methodIndices[methodKey];
//                    [indices addObject:index];
//                } else {
//                    self.storage.methodIndices[methodKey] = @[index].mutableCopy;
//                }
                if (self.isUserStorage) {
                    [self.userStorage addMethodIndex:index];
                } else {
                    [self.sysStorage addMethodIndex:index];
                }
            }
        }
    }];
}

- (void)addFileIndexForFileInPath:(NSString *)path {
    SGFileIndex *index = [SGFileIndex new];
    NSString *relativePath = [SGFileUtil relativePathFromPath:path];
    index.filePath = relativePath;
    index.commonName = [SGFileUtil commonNameForFileNamed:index.fileName];
    if (self.isUserStorage) {
        [self.userStorage addFileIndex:index];
    } else {
        [self.sysStorage addFileIndex:index];
    }
}

- (void)startIndexingAtPath:(NSString *)path {
    [self searchFiles:path];
}

#pragma mark 索引建立
- (void)createIndexForPath:(NSString *)forPath toPath:(NSString *)toPath {
    // create index
    regex_barrier(^{
        [self startIndexingAtPath:forPath];
    });
    // save index
    regex_barrier(^{
        [NSKeyedArchiver archiveRootObject:self.sysStorage toFile:toPath];
    });
}

- (void)createIndexForPath:(NSString *)forPath toPath:(NSString *)toPath finish:(void (^)())finish {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // create index
        regex_barrier(^{
            [self startIndexingAtPath:forPath];
        });
        // save index
        regex_barrier(^{
            SGIndexStorage *storage = nil;
            if (self.isUserStorage) {
                storage = self.userStorage;
            } else {
                storage = self.sysStorage;
            }
            [NSKeyedArchiver archiveRootObject:storage toFile:toPath];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finish) {
                finish();
            }
        });
    });
}

#pragma mark 索引加载
- (void)loadSystemIndexWithCallback:(void (^)())finish {
    // 记录是否已经加载过系统库以及系统库的版本
    NSString *key = @"SystemLibraryVersionKey";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [defaults objectForKey:key];
    if (version) {
        // 已经存储了信息，则直接加载系统库
        NSString *indexPath = [[SGFileUtil indexPath] stringByAppendingPathComponent:systemIndexName];
        SGIndexStorage *storage = [NSKeyedUnarchiver unarchiveObjectWithFile:indexPath];
        self.sysStorage = storage;
//        for (NSString *key in self.sysStorage.fileIndices) {
//            NSArray<SGFileIndex *> *indices = self.sysStorage.fileIndices[key];
//            for (SGFileIndex *index in indices) {
//                NSLog(@"index path = %@",index.filePath);
//            }
//        }
    } else {
        // 未存储，则从Bundle中解压
        [MBProgressHUD showMessage:@"Init components for first use"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SysInit.zip" ofType:nil];
            [SSZipArchive unzipFileAtPath:filePath toDestination:[SGFileUtil rootPath] overwrite:YES password:nil error:nil];
            [defaults setObject:@"1.0" forKey:key];
            [defaults synchronize];
            // 加载库
            NSString *indexPath = [[SGFileUtil indexPath] stringByAppendingPathComponent:systemIndexName];
            SGIndexStorage *storage = [NSKeyedUnarchiver unarchiveObjectWithFile:indexPath];
            self.sysStorage = storage;
//            for (NSString *key in self.sysStorage.fileIndices) {
//                NSArray<SGFileIndex *> *indices = self.sysStorage.fileIndices[key];
//                for (SGFileIndex *index in indices) {
//                    NSLog(@"index path = %@",index.filePath);
//                }
//            }
            // 完成
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                if (finish) {
                    finish();
                }
            });
        });
    }
}

- (void)loadUserIndexWithCallback:(void (^)())finish {
    NSString *indexPath = [[SGFileUtil indexPath] stringByAppendingPathComponent:userIndexName];
    SGIndexStorage *storage = [NSKeyedUnarchiver unarchiveObjectWithFile:indexPath];
    if (storage) {
        self.userStorage = storage;
        if (finish) {
            finish();
        }
    } else {
        // 建立索引
        [self createUserIndex:^{
            if (finish) {
                finish();
            }
        }];
    }
}

- (void)createUserIndex:(void (^)())finish {
    self.isUserStorage = YES;
    NSString *forPath = [SGFileUtil rootPath];
    NSString *toPath = [[SGFileUtil indexPath] stringByAppendingPathComponent:userIndexName];
    // if exists, remove at first
    if ([[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:toPath error:nil];
    }
    // remove all index in user storage
    self.userStorage = [SGIndexStorage new];
    [self createIndexForPath:forPath toPath:toPath finish:^{
        if (finish) {
            finish();
        }
    }];
}

#pragma mark 系统预留方法
- (void)systemReindexingWithCallback:(void (^)())finish {
    NSString *indexFilePath = [[SGFileUtil indexPath] stringByAppendingPathComponent:systemIndexName];
    self.isUserStorage = NO;
    [MBProgressHUD showMessage:@"Init components for first use"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SysLib.zip" ofType:nil];
        [SSZipArchive unzipFileAtPath:filePath toDestination:[SGFileUtil rootPath] overwrite:YES password:nil error:nil];
        [self createIndexForPath:[SGFileUtil sysLibPath] toPath:indexFilePath finish:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"Init succeed"];
                self.isUserStorage = YES;
                if (finish) {
                    finish();
                }
            });
        }];
    });
}

#pragma mark 索引查询
- (NSArray<SGClassIndex *> *)indicesForClassNamed:(NSString *)className {
    SGClassIndex *sysIndex = self.sysStorage.classIndices[className];
    SGClassIndex *userIndex = self.userStorage.classIndices[className];
    NSMutableArray *indices = @[].mutableCopy;
    if (sysIndex) {
        [indices addObject:sysIndex];
    }
    if (userIndex) {
        [indices addObject:userIndex];
    }
    return indices;
}

- (NSArray<SGFileIndex *> *)indicesForFileNamed:(NSString *)fileName {
    NSString *commonName = [SGFileUtil commonNameForFileNamed:fileName];
    NSMutableArray *indices = @[].mutableCopy;
    NSArray *sysIndices = self.sysStorage.fileIndices[commonName];
    NSArray *userIndices = self.userStorage.fileIndices[commonName];
    if (sysIndices.count) {
        [indices addObjectsFromArray:sysIndices];
    }
    if (userIndices.count) {
        [indices addObjectsFromArray:userIndices];
    }
    return indices;
}

- (NSArray<SGMethodIndex *> *)indicesForMethodKey:(NSString *)methodKey {
    NSMutableArray *indices = @[].mutableCopy;
    NSArray *sysIndices = self.sysStorage.methodIndices[methodKey];
    NSArray *userIndices = self.userStorage.methodIndices[methodKey];
    if (sysIndices.count) {
        [indices addObjectsFromArray:sysIndices];
    }
    if (userIndices.count) {
        [indices addObjectsFromArray:userIndices];
    }
    return indices;
}

#pragma mark 懒加载
- (SGIndexStorage *)sysStorage {
    if (_sysStorage == nil) {
        _sysStorage = [SGIndexStorage new];
    }
    return _sysStorage;
}

- (SGIndexStorage *)userStorage {
    if (_userStorage == nil) {
        _userStorage = [SGIndexStorage new];
    }
    return _userStorage;
}

@end
