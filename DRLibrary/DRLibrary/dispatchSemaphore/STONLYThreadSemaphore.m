//
//  STONLYThreadSemaphore.m
//  DRLibrary
//
//  Created by Wang Huiguang on 16/10/27.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import "STONLYThreadSemaphore.h"

#define LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

@implementation STONLYThreadSemaphore{
    NSMutableDictionary *_dict;
    dispatch_semaphore_t _lock;
}


+ (instancetype)shareInstance
{
    static STONLYThreadSemaphore *stonly;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!stonly) {
            stonly = [STONLYThreadSemaphore new];
            stonly->_lock = dispatch_semaphore_create(1);
            stonly->_dict = [[NSMutableDictionary alloc] init];
        }
    });
    return stonly;
}

- (void)semaphoreLock:(NSString *)sem
{
    dispatch_semaphore_t lock;
    LOCK(lock = [_dict objectForKey:sem];
         if (!lock) {
             lock = dispatch_semaphore_create(1);
             [_dict setObject:lock forKey:sem];
         });
    
    if (lock) {
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    }
}

- (void)semaphoreUNLock:(NSString *)sem
{
    dispatch_semaphore_t lock;
    LOCK(lock= [_dict objectForKey:sem]);
    
    if (lock) {
        dispatch_semaphore_signal(lock);
    }
}

@end
