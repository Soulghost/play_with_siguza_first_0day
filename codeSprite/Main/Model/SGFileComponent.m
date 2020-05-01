//
//  SGFileComponent.m
//  codeSprite
//
//  Created by 11 on 12/19/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import "SGFileComponent.h"

@implementation SGFileComponent

- (NSMutableArray *)components{
    if (_components == nil) {
        _components = [NSMutableArray array];
    }
    return _components;
}

@end
