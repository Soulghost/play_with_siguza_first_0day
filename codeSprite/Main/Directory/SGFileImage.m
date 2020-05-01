//
//  SGFileImage.m
//  codeSprite
//
//  Created by soulghost on 27/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGFileImage.h"

#define CourierFont(font) [UIFont fontWithName:@"Courier" size:font]

#define SingleFont CourierFont(26)
#define DoubleFont CourierFont(22)

@interface SGFileImage ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, assign) CGFloat nameOffsetY;

@end

@implementation SGFileImage

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [UIImageView new];
        self.imageView = imageView;
        [self addSubview:imageView];
        UILabel *nameLabel = [UILabel new];
        nameLabel.font = SingleFont;
        nameLabel.textColor = [UIColor redColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
    }
    return self;
}

- (void)setImageType:(SGFileImageType)imageType {
    _imageType = imageType;
    self.nameLabel.hidden = YES;
    switch (_imageType) {
        case SGFileImageTypeFile:
            self.imageView.image = [UIImage imageNamed:@"FileBg"];
            self.nameLabel.hidden = NO;
            break;
        case SGFileImageTypeFolder:
            self.imageView.image = [UIImage imageNamed:@"folderNav_folder"];
            break;
        case SGFileImageTypeZip:
            self.imageView.image = [UIImage imageNamed:@"folderNav_zip"];
            break;
        default:
            break;
    }
}

- (void)setExtensionName:(NSString *)extensionName {
    _extensionName = [extensionName copy];
    NSString *nameToDisplay = extensionName;
    // font choose
    switch (extensionName.length) {
        case 1:
            self.nameLabel.font = CourierFont(26);
            self.nameOffsetY = 0;
            break;
        case 2:
            self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
            self.nameOffsetY = 0;
            break;
        case 3:
            self.nameLabel.font = [UIFont boldSystemFontOfSize:14];
            self.nameOffsetY = -5;
            break;
        case 4:
            self.nameLabel.font = [UIFont boldSystemFontOfSize:12];
            self.nameOffsetY = -5;
            break;
        default:
            if (extensionName.length > 0) {
                nameToDisplay = [self.extensionName substringToIndex:1];
                self.nameLabel.font = CourierFont(26);
                self.nameOffsetY = 0;
            }
    }
    
    if ([extensionName isEqualToString:@"h"]) {
        self.nameLabel.textColor = RGB(174, 21, 43);
    } else if ([extensionName isEqualToString:@"m"]) {
        self.nameLabel.textColor = RGB(112, 78, 161);
    } else {
        self.nameLabel.textColor = RGB(90, 78, 161);
    }
    self.nameLabel.text = nameToDisplay;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    if (!self.nameLabel.font) {
        return;
    }
    CGFloat labelW = self.frame.size.width;
    CGFloat labelH = [self.nameLabel.text sizeWithAttributes:@{NSFontAttributeName:self.nameLabel.font}].height;
    CGFloat labelX = 0;
    CGFloat labelY = self.frame.size.height - labelH + self.nameOffsetY;
    self.nameLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
}

@end
