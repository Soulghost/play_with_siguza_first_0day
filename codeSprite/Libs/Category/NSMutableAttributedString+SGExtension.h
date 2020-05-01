//
//  NSMutableAttributedString+SGExtension.h
//  codeSprite
//
//  Created by soulghost on 25/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (SGExtension)

- (void)renderInRegex:(NSString *)regex withColor:(UIColor *)color;

@end
