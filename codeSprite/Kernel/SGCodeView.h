//
//  SGCodeView.h
//  codeSprite
//
//  Created by 11 on 12/18/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGFileIndex;

@interface SGCodeView : UIView

@property (nonatomic, copy) NSString *code;
@property (nonatomic, strong) SGFileIndex *index;

@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, strong) NSArray *segments;

@end
