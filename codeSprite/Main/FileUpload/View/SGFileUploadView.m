//
//  SGFileUploadView.m
//  codeSprite
//
//  Created by soulghost on 13/5/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGFileUploadView.h"

@interface SGFileUploadView ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, weak) UILabel *descLabel;
@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation SGFileUploadView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (NSString *)descTextWithAddress:(NSString *)address {
    return [NSString stringWithFormat:@"1. Please make sure your iPhone and PC is connected to the same WiFi\n\n2. Open the URL below in a browser:\n\n%@\n\n3. When click the submit button on the website, please wait until the page finish loading",address];
}

- (void)commonInit {
    self.backgroundColor = RGB(244, 244, 244);
    UIScrollView *scrollView = [UIScrollView new];
    self.scrollView = scrollView;
    [self addSubview:scrollView];
    UIImage *image = [UIImage imageNamed:@"fileUpload_WiFi"];
    self.imageSize = image.size;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView = imageView;
    [self.scrollView addSubview:imageView];
    UILabel *descLabel = [UILabel new];
    descLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    descLabel.numberOfLines = 0;
    descLabel.text = [self descTextWithAddress:@"Fetching..."];
    self.descLabel = descLabel;
    [self.scrollView addSubview:descLabel];
}

- (void)setAddress:(NSString *)address {
    self.descLabel.text = [self descTextWithAddress:address];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.imageSize.width || !self.imageSize.height || !self.descLabel.font) {
        return;
    }
    CGSize contentSize = self.frame.size;
    self.scrollView.frame = self.bounds;
    CGFloat imageW = contentSize.width * 0.8f;
    CGFloat display2RealFactor = imageW / self.imageSize.width;
    CGFloat imageH = self.imageSize.height * display2RealFactor;
    self.imageView.mj_size = CGSizeMake(imageW, imageH);
    self.imageView.center = CGPointMake(contentSize.width * 0.5f, imageH * 0.5f + 60);
    CGSize labelSize = [self.descLabel.text boundingRectWithSize:CGSizeMake(contentSize.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.descLabel.font} context:nil].size;
    CGFloat labelW = labelSize.width;
    CGFloat labelH = labelSize.height;
    CGFloat labelX = (contentSize.width - labelW) * 0.5f;
    CGFloat labelY = CGRectGetMaxY(self.imageView.frame) + 20;
    self.descLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.descLabel.frame) + 20);
}

@end
