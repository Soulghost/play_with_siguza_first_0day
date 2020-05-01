//
//  SGCodeTextView.m
//  codeSprite
//
//  Created by soulghost on 26/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGCodeTextView.h"
#import "SGLayoutManager.h"

@interface SGCodeTextView ()

@property (nonatomic, strong) SGLayoutManager *layoutMgr;

@end

@implementation SGCodeTextView

- (instancetype)initWithFrame:(CGRect)frame {
    // setup for linenum layout manager
    SGLayoutManager *layoutMgr = [SGLayoutManager new];
    self.layoutMgr = layoutMgr;
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}];
    textContainer.widthTracksTextView = YES;
    [layoutMgr addTextContainer:textContainer];
    NSTextStorage *textStorage = [NSTextStorage new];
    [textStorage removeLayoutManager:textStorage.layoutManagers.firstObject];
    [textStorage addLayoutManager:layoutMgr];
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    CGFloat height = MAX(CGRectGetHeight(bounds), self.contentSize.height);
    CGContextSetFillColorWithColor(context, RGB(247, 247, 247).CGColor);
    CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y, self.layoutMgr.gutterWidth, height));
    CGContextSetFillColorWithColor(context, RGB(234, 234, 234).CGColor);
    CGContextFillRect(context, CGRectMake(self.layoutMgr.gutterWidth, bounds.origin.y, 0.5, height));
    [super drawRect:rect];
}

@end
