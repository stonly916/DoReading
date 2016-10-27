//
//  NSDictionary+containKeyOrValue.h
//  DRBase
//
//  Created by Wang Huiguang on 16/5/27.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (containKeyOrValue)

- (BOOL)containKey:(NSString *)key;
- (BOOL)containValue:(id)value;

@end

@interface NSMutableDictionary (safety)

- (void)DRSetObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end