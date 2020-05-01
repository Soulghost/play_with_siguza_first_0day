//
//  SGFileNavigationController.m
//  codeSprite
//
//  Created by soulghost on 27/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGFileNavigationController.h"
#import "SGFileUploadViewController.h"

@implementation SGFileNavigationController

+ (void)initialize {
    [self setupBarButtoTheme];
    [self setupBarTheme];
}

+ (void)setupBarButtoTheme {
    // apperance方法可以获取用于设置所有item主题的代理
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    // 将要设置的属性放到字典中，包括颜色、字体、无阴影
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor brownColor];
    textAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeZero;
    textAttrs[NSShadowAttributeName] = shadow;
    // 为导航栏按钮的Normal和Selected状态分别设置
    [item setTintColor:[UIColor whiteColor]];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateHighlighted];
}

+ (void)setupBarTheme {
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setTintColor:[UIColor brownColor]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    if (self.viewControllers.count > 2) {
        if ([viewController respondsToSelector:@selector(popToRoot)]) {
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"•••" style:UIBarButtonItemStylePlain target:viewController action:@selector(popToRoot)];
        }
    } else {
        UIBarButtonItem *wifiBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(wifiClick)];
        wifiBtn.tintColor = [UIColor brownColor];
        viewController.navigationItem.rightBarButtonItem = wifiBtn;
    }
}

- (void)popToRoot {}

- (void)wifiClick {
    [self presentViewController:[[SGFileNavigationController alloc] initWithRootViewController:[SGFileUploadViewController new]] animated:YES completion:nil];
}

@end
