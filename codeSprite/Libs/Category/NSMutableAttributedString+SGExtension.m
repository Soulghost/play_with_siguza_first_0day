//
//  NSMutableAttributedString+SGExtension.m
//  codeSprite
//
//  Created by soulghost on 25/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "NSMutableAttributedString+SGExtension.h"
#import "RegexKitLite.h"

@implementation NSMutableAttributedString (SGExtension)

- (void)renderInRegex:(NSString *)regex withColor:(UIColor *)color {
    [self.string enumerateStringsMatchedByRegex:regex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        [self addAttribute:NSForegroundColorAttributeName value:color range:*capturedRanges];
    }];
}

@end
