//
//  NSDictionary+containKeyOrValue.m
//  DRBase
//
//  Created by Wang Huiguang on 16/5/27.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import "NSDictionary+containKeyOrValue.h"

@implementation NSDictionary (containKeyOrValue)

- (BOOL)containKey:(NSString *)key
{
    NSObject *obj = [self objectForKey:key];
    return obj ? YES:NO;
}

- (BOOL)containValue:(id)value
{
    return [self.allValues containsObject:value];
}

@end

@implementation NSMutableDictionary (safety)

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

- (void)DRSetObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject == nil) {
        return;
    }else {
        [self setObject:anObject forKey:aKey];
    }
}

@end