//
//  STONLYThreadSemaphore.h
//  DRLibrary
//
//  Created by Wang Huiguang on 16/10/27.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ST_SEMAPHORE_LOCK(semString,...) \
[[STONLYThreadSemaphore shareInstance] semaphoreLock:semString];\
__VA_ARGS__;\
[[STONLYThreadSemaphore shareInstance] semaphoreUNLock:semString];

@interface STONLYThreadSemaphore : NSObject

+ (instancetype)shareInstance;

- (void)semaphoreLock:(NSString *)sem;
- (void)semaphoreUNLock:(NSString *)sem;

@end
