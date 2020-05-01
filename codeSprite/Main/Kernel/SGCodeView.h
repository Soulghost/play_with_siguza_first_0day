//
//  SGCodeView.h
//  codeSprite
//
//  Created by 11 on 12/18/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGOriginFileIndex;

@interface SGCodeView : UIView

@property (nonatomic, copy) NSString *code;
@property (nonatomic, strong) SGIndex *index;

@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, strong) NSArray *segments;
@property (nonatomic, weak) UIViewController *viewController;

@end
