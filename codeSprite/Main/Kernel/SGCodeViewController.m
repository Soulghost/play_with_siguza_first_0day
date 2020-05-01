//
//  SGCodeViewController.m
//  codeSprite
//
//  Created by 11 on 12/19/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import "SGCodeViewController.h"
#import "SGCodeView.h"
#import "SGFileComponent.h"
#import "PKRevealController.h"

@interface SGCodeViewController () <PKRevealing>

@property (nonatomic, weak) SGCodeView *codeView;

@end

@implementation SGCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.file.name;
    self.revealController.delegate = self;
    if (_index == nil) {
        [self setFile:_file];
    }else{
        [self setIndex:_index];
    }
    UIButton *titleBtn = [UIButton new];
    titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [titleBtn addTarget:self action:@selector(titleClick) forControlEvents:UIControlEventTouchUpInside];
    [titleBtn setTitle:[NSString stringWithFormat:@"☞%@",self.title] forState:UIControlStateNormal];
    [titleBtn setTitleColor:RGB(24, 97, 242) forState:UIControlStateNormal];
    [titleBtn setTitleColor:RGB(0, 0, 0) forState:UIControlStateHighlighted];
    self.navigationItem.titleView = titleBtn;
}

- (void)titleClick {
    NSArray<SGFileIndex *> *fileIndices = [[SGIndexManager sharedManager] indicesForFileNamed:self.title];
    if (fileIndices.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SGCodeViewShouldJumpNotification object:@{@"type":@"file", @"index":fileIndices}];
    } else {
        [MBProgressHUD showError:@"?"];
    }
}

- (void)loadView {
    SGCodeView *codeView = [SGCodeView new];
    self.view = codeView;
    self.codeView = codeView;
    self.codeView.viewController = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(codeViewShouldJump:) name:SGCodeViewShouldJumpNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFile:(SGFileComponent *)file {
    _file = file;
    NSData *codeData = [NSData dataWithContentsOfFile:self.file.path];
    self.codeView.code = [[NSString alloc] initWithData:codeData encoding:NSUTF8StringEncoding];
}

- (void)setIndex:(SGIndex *)index {
    _index = index;
    self.title = index.fileName;
    self.codeView.index = index;
}

#pragma mark Notification Callback
- (void)codeViewShouldJump:(NSNotification *)nof {
    NSDictionary *params = nof.object;
    NSString *type = params[@"type"];
    if ([type isEqualToString:@"file"]) {
        NSArray<SGFileIndex *> *fileIndices = params[@"index"];
        NSMutableArray *indexTitles = @[].mutableCopy;
        for (NSUInteger i = 0; i < fileIndices.count; i++) {
            SGFileIndex *index = fileIndices[i];
            [indexTitles addObject:index.fileName];
        }
        [[[SGBlockActionSheet alloc] initWithTitle:@"File to Jump" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                return;
            }
            SGFileIndex *index = fileIndices[buttonIndex - 1];
            SGFileComponent *file = [SGFileComponent new];
            file.name = index.fileName;
            file.path = index.filePath;
            SGCodeViewController *destVc = [SGCodeViewController new];
            [self.navigationController pushViewController:destVc animated:YES];
            destVc.file = file;
        } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitlesArray:indexTitles] showInView:self.view];
    } else if ([type isEqualToString:@"class"]) {
        NSArray<SGClassIndex *> *classIndices = params[@"index"];
        if (classIndices.count == 1) {
            SGClassIndex *index = [classIndices firstObject];
            SGFileComponent *file = [SGFileComponent new];
            file.name = index.fileName;
            file.path = index.filePath;
            SGCodeViewController *destVc = [SGCodeViewController new];
            [self.navigationController pushViewController:destVc animated:YES];
            destVc.file = file;
        } else if (classIndices.count) {
            NSMutableArray *indexTitles = @[].mutableCopy;
            for (NSUInteger i = 0; i < classIndices.count; i++) {
                SGClassIndex *index = classIndices[i];
                [indexTitles addObject:[NSString stringWithFormat:@"%@ - <%@>",index.className, index.fileName]];
            }
            [[[SGBlockActionSheet alloc] initWithTitle:@"Class to Jump" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    return;
                }
                SGClassIndex *index = classIndices[buttonIndex - 1];
                SGFileComponent *file = [SGFileComponent new];
                file.name = index.fileName;
                file.path = index.filePath;
                SGCodeViewController *destVc = [SGCodeViewController new];
                [self.navigationController pushViewController:destVc animated:YES];
                destVc.file = file;
            } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitlesArray:indexTitles] showInView:self.view];
        }

    } else if ([type isEqualToString:@"method"]) {
        NSArray<SGMethodIndex *> *indices = params[@"index"];
        NSMutableArray *indexTitles = @[].mutableCopy;
        for (NSUInteger i = 0; i < indices.count; i++) {
            SGMethodIndex *index = indices[i];
            [indexTitles addObject:[NSString stringWithFormat:@"%@ - <%@>",index.methodName, index.fileName]];
        }
        [[[SGBlockActionSheet alloc] initWithTitle:@"Method to Jump" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                return;
            }
            SGMethodIndex *index = indices[buttonIndex - 1];
            SGCodeViewController *destVc = [SGCodeViewController new];
            [self.navigationController pushViewController:destVc animated:YES];
            destVc.index = index;
        } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitlesArray:indexTitles] showInView:self.view];
    }
}

@end
