//
//  SGFileFolderViewController.h
//  codeSprite
//
//  Created by 11 on 12/19/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGFileFolderViewController : UITableViewController

+ (instancetype)folderVcWithPath:(NSString*)path;
- (id)initWithPath:(NSString*)path;
- (void)popToRoot;

@end
