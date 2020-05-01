//
//  AppDelegate.m
//  codeSprite
//
//  Created by 11 on 12/18/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import "AppDelegate.h"
#import "SGTestViewController.h"
#import "PKRevealController.h"
#import "SGCodeViewController.h"
#import "DTNavigationController.h"
#import "SGFileFolderViewController.h"
#import "SGIndexManager.h"
#import "YALFoldingTabBarController.h"
#import "YALTabBarItem.h"
#import "YALAnimatingTabBarConstants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupTabbar];
    [self setupIndex];
    return YES;
}

- (void)setupTabbar{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    YALFoldingTabBarController *tabbarVc = [[YALFoldingTabBarController alloc] init];
    //prepare leftBarItems
    YALTabBarItem *item1 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"nearby_icon"]
                                                      leftItemImage:nil
                                                     rightItemImage:nil];
    tabbarVc.leftBarItems = @[item1];
    YALTabBarItem *item4 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"settings_icon"]
                                                      leftItemImage:nil
                                                     rightItemImage:nil];
    
    tabbarVc.rightBarItems = @[item4];
    tabbarVc.centerButtonImage = [UIImage imageNamed:@"plus_icon"];
    //customize tabBarView
    tabbarVc.tabBarView.extraTabBarItemHeight = YALExtraTabBarItemsDefaultHeight;
    tabbarVc.tabBarView.offsetForExtraTabBarItems = YALForExtraTabBarItemsDefaultOffset;
    tabbarVc.tabBarView.backgroundColor = [UIColor clearColor];
    tabbarVc.tabBarView.tabBarColor = RGBA(224, 224, 224, 0.8);
    tabbarVc.tabBarView.dotColor = [UIColor whiteColor];
    tabbarVc.tabBarViewHeight = YALTabBarViewDefaultHeight;
    tabbarVc.tabBarView.tabBarViewEdgeInsets = YALTabBarViewHDefaultEdgeInsets;
    tabbarVc.tabBarView.tabBarItemsEdgeInsets = YALTabBarViewItemsDefaultEdgeInsets;
    // first Vc
    NSString *rootPath = @"/";
    SGFileFolderViewController *fileVc = [SGFileFolderViewController folderVcWithPath:rootPath];
    fileVc.title = @"Files";
    SGFileNavigationController *mainNav = [[SGFileNavigationController alloc] initWithRootViewController:fileVc];
    // second Vc
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UITableViewController *settingsVc = sb.instantiateInitialViewController;
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsVc];
    tabbarVc.viewControllers = @[mainNav,settingsNav];
    self.window.rootViewController = tabbarVc;
    [self.window makeKeyAndVisible];
}

- (void)setupIndex {
    [[SGIndexManager sharedManager] loadUserIndexWithCallback:^{
        
    }];
}

@end
