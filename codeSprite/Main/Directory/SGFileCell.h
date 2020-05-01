//
//  SGFileCell.h
//  codeSprite
//
//  Created by 11 on 12/23/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CellHeight 60
#define CellMargin 1

@class SGFileComponent;

@interface SGFileCell : UITableViewCell

+ (instancetype)fileCellWithTableView:(UITableView *)tableView fileComponent:(SGFileComponent *)file;

@end
