//
//  SGFileFolderViewController.m
//  codeSprite
//
//  Created by 11 on 12/19/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import "SGFileFolderViewController.h"
#import "SGFileComponent.h"
#import "SGCodeViewController.h"
#import "SGFileUploadViewController.h"
#import "SSZipArchive.h"
#import "SGIndexManager.h"
#import "SGFileCell.h"
#import <QuickLook/QuickLook.h>

#define ActionSheetWifiTag 1
#define ActionSheetJumpTag 2
#define ActionSheetHeaderOrImplementTag 3

@interface SGFileFolderViewController () <UIActionSheetDelegate,UIAlertViewDelegate,SSZipArchiveDelegate>

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, strong) SGFileComponent *currentFile;

@end

@implementation SGFileFolderViewController

+ (instancetype)folderVcWithPath:(NSString *)path{
    SGFileFolderViewController *folder = [[SGFileFolderViewController alloc] initWithPath:path];
    return folder;
}

- (id)initWithPath:(NSString *)path{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        self.path = path;
        NSArray<NSString*> *pathComps = [self.path componentsSeparatedByString:@"/"];
        self.title = pathComps[pathComps.count - 1];
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    return self;
}

- (NSMutableArray *)files{
    if(_files == nil){
        _files = [NSMutableArray array];
    }
    return _files;
}

- (void)loadFiles{
    BOOL isDir;
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr fileExistsAtPath:self.path isDirectory:&isDir];
    [self.files removeAllObjects];
    if (isDir) {
        NSArray *pathes = [mgr contentsOfDirectoryAtPath:self.path error:nil];
        for(NSString *ph in pathes){
            if ([ph isEqualToString:@"__MACOSX"] || [ph hasPrefix:@"."]) {
                continue;
            }
            SGFileComponent *comp = [[SGFileComponent alloc] init];
            comp.name = ph;
            isDir = YES;
            comp.path = [self.path stringByAppendingPathComponent:ph];
            [mgr fileExistsAtPath:comp.path isDirectory:&isDir];
            comp.isDir = isDir;
            [self.files addObject:comp];
        }
    }else{
        SGFileComponent *comp = [[SGFileComponent alloc] init];
        comp.path = self.path;
        comp.isDir = NO;
        NSArray<NSString*> *pathComps = [self.path componentsSeparatedByString:@"/"];
        comp.name = pathComps[pathComps.count - 1];
        [self.files addObject:comp];
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = RGB(244, 244, 244);
    [self setupRefresh];
}

- (void)setupRefresh {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadFiles];
        [self.tableView.mj_header endRefreshing];
    }];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.mj_header = header;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadFiles];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SGIndexManager *mgr = [SGIndexManager sharedManager];
        [mgr loadSystemIndexWithCallback:^{
            [self loadFiles];
        }];
    });
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SGFileComponent *file = self.files[indexPath.row];
    SGFileCell *cell = [SGFileCell fileCellWithTableView:tableView fileComponent:file];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CellHeight;
}

- (BOOL)checkCodeFile:(NSString *)fileName{
    NSArray *validSuffix = @[@".m",@".h",@".mm",@".c",@".cpp",@".php",@".java",@".py"];
    NSInteger cnt = validSuffix.count;
    for (NSInteger i = 0; i < cnt; i++) {
        if ([fileName hasSuffix:validSuffix[i]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkWebFile:(NSString *)fileName{
    NSArray *validSuffix = @[@".doc",@".docx",@".xls",@".ppt",@".png",@".jpeg",@".jpg",@".gif",@".pdf"];
    NSInteger cnt = validSuffix.count;
    for (NSInteger i = 0; i < cnt; i++) {
        if ([fileName hasSuffix:validSuffix[i]]) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SGFileComponent *file = self.files[indexPath.row];
    self.currentFile = file;
    if (file.isDir) {
        SGFileFolderViewController *folderVc = [SGFileFolderViewController folderVcWithPath:file.path];
        [self.navigationController pushViewController:folderVc animated:YES];
    }else{
        if([file.name hasSuffix:@".zip"]){ // can unzip with SSZipArchive
            [[[SGBlockActionSheet alloc] initWithTitle:@"请选择操作" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [SSZipArchive unzipFileAtPath:self.currentFile.path toDestination:[SGFileUtil rootPath] delegate:self];
                    });
                    [MBProgressHUD showMessage:@"正在解压"];
                }
            } cancelButtonTitle:@"取消" destructiveButtonTitle:@"解压" otherButtonTitlesArray:nil] showInView:self.view];
            
        }else if([[SGFileUtil sharedUtil] isValidPreviewFileNamed:file.name]){
            [[SGFileUtil sharedUtil] previewFile:file.path forViewController:self];
        }else{
            SGCodeViewController *codeVc = [[SGCodeViewController alloc] init];
            [self.navigationController pushViewController:codeVc animated:YES];
            codeVc.file = file;
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:{
            NSFileManager *mgr = [NSFileManager defaultManager];
            SGFileComponent *file = self.files[indexPath.row];
            NSError *err = nil;
            [mgr removeItemAtPath:file.path error:&err];
            if (!err) {
                [self.files removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];
            }else{
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",err]];
            }
            break;
        }
        default:
            break;
    }
}


- (void)navigationControllerActionButtonClick{
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"wifi传文件", nil];
    ac.tag = ActionSheetWifiTag;
    [ac showInView:self.view];
}

#pragma mark SSZipArchiver Delegate
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadFiles];
        [[SGIndexManager sharedManager] createUserIndex:nil];
        [MBProgressHUD hideHUD];
    });
}

#pragma mark Pop Interface Implemetation
- (void)popToRoot {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
