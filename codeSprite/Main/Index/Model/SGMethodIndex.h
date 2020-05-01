//
//  SGMethodIndex.h
//  codeSprite
//
//  Created by soulghost on 28/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGIndex.h"

@interface SGMethodIndex : SGIndex

@property (nonatomic, copy) NSString *methodKey;
@property (nonatomic, copy, readonly) NSString *methodName;

@end
