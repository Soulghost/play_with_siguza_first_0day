//
//  TextSegment.h
//  codeSprite
//
//  Created by 11 on 12/18/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TextSegmentType) {
    TextSegmentTypeClass,
    TextSegmentTypeMethod
};

@interface TextSegment : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) TextSegmentType type;

@end
