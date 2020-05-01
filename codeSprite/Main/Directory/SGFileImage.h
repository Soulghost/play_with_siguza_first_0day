//
//  SGFileImage.h
//  codeSprite
//
//  Created by soulghost on 27/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, SGFileImageType){
    SGFileImageTypeFile,
    SGFileImageTypeFolder,
    SGFileImageTypeZip
};

@interface SGFileImage : UIView

@property (nonatomic, copy) NSString *extensionName;
@property (nonatomic, assign) SGFileImageType imageType;

@end
