//
//  SGFileComponent.h
//  codeSprite
//
//  Created by 11 on 12/19/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGFileComponent : NSObject 

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) BOOL isDir;
@property (nonatomic, strong) NSMutableArray *components;
@property (nonatomic, strong) NSMutableDictionary *fileMap;
@property (nonatomic, assign) NSInteger level;

@end
