//
//  SGIndex.h
//  codeSprite
//
//  Created by soulghost on 26/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGIndex : NSObject <NSCoding>

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSRange range;

@end
