//
//  SGLayoutManager.h
//  codeSprite
//
//  Created by soulghost on 26/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGLayoutManager : NSLayoutManager

@property (nonatomic, assign) CGFloat gutterWidth;
@property (nonatomic, strong) UIFont *lineNumberFont;
@property (nonatomic, strong) UIColor *lineNumberColor;

@end
