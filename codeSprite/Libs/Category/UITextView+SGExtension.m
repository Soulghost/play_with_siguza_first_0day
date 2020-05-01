//
//  UITextView+SGExtension.m
//  codeSprite
//
//  Created by soulghost on 26/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "UITextView+SGExtension.h"

@implementation UITextView (SGExtension)

- (CGRect)selectRectInRange:(NSRange )range {
    UITextPosition *begin = self.beginningOfDocument;
    UITextPosition *start = [self positionFromPosition:begin offset:range.location];
    UITextPosition *end = [self positionFromPosition:start offset:range.length];
    UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
    return [self firstRectForRange:textRange];
}

@end
