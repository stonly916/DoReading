//
//  STONLYThreadSemaphore.m
//  DRLibrary
//
//  Created by Wang Huiguang on 16/10/27.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import "STONLYThreadSemaphore.h"

#define INIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_dic) return nil; \
_lock = dispatch_semaphore_create(1); \
return self;


#define LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

@interface YYThreadSafeDictionary : NSMutableDictionary
@end

//借用YYThreadSafeDictionary
@implementation YYThreadSafeDictionary {
    NSMutableDictionary *_dic;  //Subclass a class cluster...
    dispatch_semaphore_t _lock;
}

- (instancetype)init {
    INIT(_dic = [[NSMutableDictionary alloc] init]);
}

- (id)objectForKey:(id)aKey {
    LOCK(id o = [_dic objectForKey:aKey]); return o;
}

- (void)removeObjectForKey:(id)aKey {
    LOCK([_dic removeObjectForKey:aKey]);
}

- (void)setObject:(id)anObject forKey:(id <NSCopying> )aKey {
    LOCK([_dic setObject:anObject forKey:aKey]);
}
- (void)removeAllObjects {
    LOCK([_dic removeAllObjects]);
}

@end


@implementation STONLYThreadSemaphore{
    YYThreadSafeDictionary *_dict;
}


+ (instancetype)shareInstance
{
    static STONLYThreadSemaphore *stonly;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!stonly) {
            stonly = [STONLYThreadSemaphore new];
        }
    });
    return stonly;
}

- (void)semaphoreLock:(NSString *)sem
{
    dispatch_semaphore_t lock = [_dict objectForKey:sem];
    if (!lock) {
        lock = dispatch_semaphore_create(1);
        [_dict setObject:lock forKey:sem];
    }
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
}

- (void)semaphoreUNLock:(NSString *)sem
{
    dispatch_semaphore_t lock = [_dict objectForKey:sem];
    if (lock) {
        dispatch_semaphore_signal(lock);
    }
}

@end
