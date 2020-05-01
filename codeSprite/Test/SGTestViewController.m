//
//  SGTestViewController.m
//  codeSprite
//
//  Created by 11 on 12/18/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import "SGTestViewController.h"
#import "SGCodeView.h"

@interface SGTestViewController ()

@property (nonatomic, strong) NSFileManager *manager;
@property (nonatomic, weak) SGCodeView *codeView;

@end

@implementation SGTestViewController

- (NSFileManager *)manager{
    return [NSFileManager defaultManager];
}

- (void)searchFiles:(NSString *)path{
    BOOL isDir;
    [self.manager fileExistsAtPath:path isDirectory:&isDir];
    if (isDir) {
        NSLog(@"dir");
        NSArray *pathes = [self.manager contentsOfDirectoryAtPath:path error:nil];
        for(NSString *ph in pathes){
            [self searchFiles:[path stringByAppendingPathComponent:ph]];
        }
    }else{
        if([path hasSuffix:@".m"]){
            NSLog(@"%@",path);
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            self.codeView.code = content;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
    
    CGRect frame = self.view.bounds;
    frame.size.height -= 64;
    frame.origin.y += 64;
    SGCodeView *codeView = [[SGCodeView alloc] initWithFrame:frame];
    self.codeView = codeView;
    [self.view addSubview:codeView];
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    [self searchFiles:rootPath];
    
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://42.96.168.162/SGTestViewController.m"]];
//    self.navigationItem.title = @"SGTestViewController.m";
//    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    self.codeView.code = content;
}

@end
