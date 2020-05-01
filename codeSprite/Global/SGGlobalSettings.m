//
//  SGGlobalSettings.m
//  codeSprite
//
//  Created by soulghost on 28/4/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGGlobalSettings.h"

@implementation SGGlobalSettings

+ (instancetype)sharedSettings {
    static SGGlobalSettings *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SGGlobalSettings new];
    });
    return instance;
}

@end
