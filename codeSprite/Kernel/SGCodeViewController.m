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
    self.view.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
    CGRect frame = self.view.bounds;
    frame.size.height -= 64;
    frame.origin.y += 64;
    SGCodeView *codeView = [[SGCodeView alloc] initWithFrame:frame];
    self.codeView = codeView;
    [self.view addSubview:codeView];
    
    self.revealController.delegate = self;
    if (_index == nil) {
        [self setFile:_file];
    }else{
        [self setIndex:_index];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setFile:(SGFileComponent *)file {
    _file = file;
    NSData *codeData = [NSData dataWithContentsOfFile:self.file.path];
    self.codeView.code = [[NSString alloc] initWithData:codeData encoding:NSUTF8StringEncoding];
}

- (void)setIndex:(SGFileIndex *)index {
    _index = index;
    self.codeView.index = index;
}

@end
