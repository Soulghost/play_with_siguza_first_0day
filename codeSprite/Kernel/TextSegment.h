//
//  TextSegment.h
//  codeSprite
//
//  Created by 11 on 12/18/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextSegment : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign, getter=isSpecial) BOOL special;
@property (nonatomic, assign, getter=isEmotion) BOOL emotion;

@end
