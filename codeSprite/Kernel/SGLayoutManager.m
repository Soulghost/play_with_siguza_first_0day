//
//  SGLayoutManager.m
//  codeSprite
//
//  Created by soulghost on 26/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGLayoutManager.h"

@interface SGLayoutManager ()

@property (nonatomic, assign) NSUInteger lastParaLocation;
@property (nonatomic, assign) NSUInteger lastParaNumber;

@end

@implementation SGLayoutManager

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.lineNumberFont = [UIFont fontWithName:@"Arial" size:10.0f];
    self.lineNumberColor = [UIColor grayColor];
    self.gutterWidth = 32.0f;
}

- (CGRect)paragraphRectForRange:(NSRange)range {
    range = [self.textStorage.string paragraphRangeForRange:range];
    range = [self glyphRangeForCharacterRange:range actualCharacterRange:NULL];
    CGRect startRect = [self lineFragmentRectForGlyphAtIndex:range.location effectiveRange:NULL];
    CGRect endRect = [self lineFragmentRectForGlyphAtIndex:range.location + range.length - 1 effectiveRange:NULL];
    CGRect paragraphRectForRange = CGRectUnion(startRect, endRect);
    paragraphRectForRange = CGRectOffset(paragraphRectForRange, self.gutterWidth, 8);
    return paragraphRectForRange;
}

- (NSUInteger)paragraphNumerForRange:(NSRange)charRange {
    if (charRange.location == self.lastParaLocation) {
        return self.lastParaNumber;
    } else if (charRange.location < self.lastParaLocation) {
        // backwards
        NSString *s = self.textStorage.string;
        __block NSUInteger paraNumber = self.lastParaNumber;
        [s enumerateSubstringsInRange:NSMakeRange(charRange.location, self.lastParaLocation - charRange.location) options:NSStringEnumerationByParagraphs | NSStringEnumerationSubstringNotRequired | NSStringEnumerationReverse usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            if (enclosingRange.location <= charRange.location) {
                *stop = YES;
            }
            --paraNumber;
        }];
        self.lastParaLocation = charRange.location;
        self.lastParaNumber = paraNumber;
        return paraNumber;
    } else {
        // forwards
        NSString *s = self.textStorage.string;
        __block NSUInteger paraNumber = self.lastParaNumber;
        [s enumerateSubstringsInRange:NSMakeRange(self.lastParaLocation, charRange.location - self.lastParaLocation) options:NSStringEnumerationByParagraphs | NSStringEnumerationSubstringNotRequired usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            if (enclosingRange.location >= charRange.location) {
                *stop = YES;
            }
            ++paraNumber;
        }];
        self.lastParaLocation = charRange.location;
        self.lastParaNumber = paraNumber;
        return paraNumber;
    }
}

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    NSDictionary *attrs = @{NSFontAttributeName:self.lineNumberFont, NSForegroundColorAttributeName:self.lineNumberColor};
    [self enumerateLineFragmentsForGlyphRange:glyphsToShow usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        NSRange charRange = [self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
        NSRange paraRange = [self.textStorage.string paragraphRangeForRange:charRange];
        if (charRange.location == paraRange.location) {
            CGRect gutterRect = CGRectOffset((CGRect){0, rect.origin.y, self.gutterWidth, rect.size.height}, origin.x, origin.y);
            NSUInteger paraNumber = [self paragraphNumerForRange:charRange];
            NSString *numberString = [NSString stringWithFormat:@"%@",@(paraNumber)];
            CGSize size = [numberString sizeWithAttributes:attrs];
            CGFloat offsetX = CGRectGetWidth(gutterRect) - 8 - size.width - self.gutterWidth;
            CGFloat offsetY = (CGRectGetHeight(gutterRect) - size.height) * 0.5f;
            [numberString drawInRect:CGRectOffset(gutterRect, offsetX, offsetY) withAttributes:attrs];
        }
    }];
}

- (void)processEditingForTextStorage:(NSTextStorage *)textStorage edited:(NSTextStorageEditActions)editMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange {
    [super processEditingForTextStorage:textStorage edited:editMask range:newCharRange changeInLength:delta invalidatedRange:invalidatedCharRange];
    if (invalidatedCharRange.location < self.lastParaLocation)
    {
        //  When the backing store is edited ahead the cached paragraph location, invalidate the cache and force a complete
        //  recalculation.  We cannot be much smarter than this because we don't know how many paragraphs have been deleted
        //  since the text has already been removed from the backing store.
        self.lastParaLocation = 0;
        self.lastParaNumber = 0;
    }
}

@end
