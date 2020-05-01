//
//  SGCodeViewController.h
//  codeSprite
//
//  Created by 11 on 12/19/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFileComponent.h"

@class SGFileComponent;
@class SGFileIndex;

@interface SGCodeViewController : UIViewController

@property (nonatomic, strong) SGFileComponent *file;
@property (nonatomic, strong) SGFileIndex *index;

@end
