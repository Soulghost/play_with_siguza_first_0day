//
//  SGGlobalSettings.h
//  codeSprite
//
//  Created by soulghost on 28/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGGlobalSettings : NSObject

@property (nonatomic, weak) UIViewController *bottomCodeViewController;

+ (instancetype)sharedSettings;

@end
