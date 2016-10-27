//
//  NSMutableArray+safe.m
//  DRBase
//
//  Created by Wang Huiguang on 16/10/27.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import "NSMutableArray+safe.h"

@implementation NSMutableArray (safe)

- (void)DRAddObject:(id)obj
{
    if (obj) {
        [self addObject:obj];
    }
}

@end
