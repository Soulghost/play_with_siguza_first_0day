//
//  SGFileCell.m
//  codeSprite
//
//  Created by 11 on 12/23/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import "SGFileCell.h"
#import "SGFileImage.h"
#import "SGFileComponent.h"

#define CellHeight 60

@interface SGFileCell ()

@property (nonatomic, weak) SGFileImage *iconView;
@property (nonatomic, weak) UIView *seperatorView;
@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation SGFileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        SGFileImage *iconView = [SGFileImage new];
        [self.contentView addSubview:iconView];
        self.iconView = iconView;
        UILabel *titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.backgroundColor = [UIColor clearColor];
        UIView *seperatorView = [UIView new];
        seperatorView.backgroundColor = RGB(206, 206, 206);
        self.seperatorView = seperatorView;
        [self.contentView addSubview:seperatorView];
    }
    return self;
}

+ (instancetype)fileCellWithTableView:(UITableView *)tableView fileComponent:(SGFileComponent *)file{
    static NSString *ID = @"fileCell";
    SGFileCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[SGFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // 在这里设置cell数据
    cell.titleLabel.text = file.name;
    if (file.isDir) {
        cell.iconView.imageType = SGFileImageTypeFolder;
    } else if ([file.name hasSuffix:@".zip"]){
        cell.iconView.imageType = SGFileImageTypeZip;
    } else {
        cell.iconView.imageType = SGFileImageTypeFile;
        cell.iconView.extensionName = [SGFileUtil extensionNameForFileNamed:file.name];
    }
    return cell;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat offsetX = 8;
    CGFloat cellH = self.contentView.frame.size.height;
    CGFloat iconW = 30;
    CGFloat iconH = 40;
    CGFloat iconX = 10 + offsetX;
    CGFloat iconY = (cellH - iconH) * 0.5f;
    self.iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
    
    CGFloat titleW = [UIScreen mainScreen].bounds.size.width - iconW - iconX - 40;
    CGFloat titleH = cellH;
    CGFloat titleX = CGRectGetMaxX(self.iconView.frame) + 8;
    CGFloat titleY = 0;
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    CGFloat lineW = self.contentView.frame.size.width;
    CGFloat lineH = 0.5;
    self.seperatorView.frame = CGRectMake(offsetX, cellH - lineH, lineW, lineH);
}

@end
