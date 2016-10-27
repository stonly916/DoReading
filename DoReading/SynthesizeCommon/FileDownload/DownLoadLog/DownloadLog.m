//
//  DownloadLog.m
//  pyd
//
//  Created by Wang Huiguang on 15/10/29.
//  Copyright © 2015年 iOS. All rights reserved.
//

#import "DownloadLog.h"
#import "FileDownloadRequest.h"

#define THREAD_STORE_FLAG 0

@interface DownloadLog(){
    OSSpinLock _storeLock;
}


@property (nonatomic, copy) NSString *downHistoryDirectory;
//下载日志
@property (nonatomic, strong) NSMutableDictionary *downLogDict;
@end


@implementation DownloadLog

- (NSString *)downHistoryDirectory
{// 文件存储目录 Document
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = paths.firstObject;
    return document;
}

- (instancetype)init
{
    if (self = [super init]) {
        _storeLock = OS_SPINLOCK_INIT;
        
        _downHistoryPath = [self.downHistoryDirectory stringByAppendingString:@"/downLog"];

        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:_downHistoryPath];
        if (dict == nil) {
            NSLog(@"重新创建downLog!!!");
            dict = [NSMutableDictionary dictionary];
        }
        
        _downLogDict = [NSMutableDictionary dictionary];
        
        for (NSString *key in dict.allKeys) {
            NSDictionary *d = [dict objectForKey:key];
            NSError *error = nil;
            DownLogModel *model = [MTLJSONAdapter modelOfClass:[DownLogModel class] fromJSONDictionary:d error:&error];
            if (error) {
                NSLog(@"%@",error);
            }else {
                [_downLogDict setObject:model forKey:key];
            }
        }
        
    }
    return self;
}

#pragma mark - 单例
+ (DownloadLog *)sharedInstance
{
    static dispatch_once_t once;
    static DownloadLog *singleManager;
    dispatch_once(&once, ^{
        singleManager = [[DownloadLog alloc] init];
    });
    return singleManager;
}

#pragma mark - 设置下载目录
-(NSString *)fileDownloaderDirectory
{// 文件下载临时目录 Document/FileDownload
    static NSString *_fileDownloadDirectory;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *document = paths.firstObject;
        _fileDownloadDirectory = [document stringByAppendingString:@"/FileDownload/"];
        [CFileHandle createDirectoryAtPath:_fileDownloadDirectory];
    });
    return _fileDownloadDirectory;
}

- (NSString *)fileStoreDirectory
{// 文件存储目录 Document/FileStore
    static NSString *_fileStoreDirectory;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *document = paths.firstObject;
        _fileStoreDirectory = [document stringByAppendingString:@"/FileStore/"];
        [CFileHandle createDirectoryAtPath:_fileStoreDirectory];
    });
    return _fileStoreDirectory;
}
#pragma mark - 缓存路径
- (NSString *)getCachePathWith:(NSString *)name
{
    return [self.fileDownloaderDirectory stringByAppendingFormat:@"%@.downDR",name];
}
#pragma mark - 下载路径
- (NSString *)getDownPathWith:(NSString *)name
{
    return [self.fileStoreDirectory stringByAppendingString:name];
}

- (BOOL)addProgressToDownLog:(CGFloat)progress byName:(NSString *)name
{
    if (name.length > 0) {
        DownLogModel *model = [self.downLogDict objectForKey:name];
        if (nil != model) {
            model.progress = progress;
            NSLog(@"%@下载进度_%.3f",name,progress);
        }else {
            NSLog(@"addProgress_%@_对应模型查找失败",name);
        }
//        [self storeDownLog];
        return YES;
    }
    return NO;
}

#pragma mark - 存储信息到日志
- (BOOL)addToDownLog:(FileDownloadRequest *)request
{
    if (nil == request) {
        return NO;
    }
    
    if (![CFileHandle containFileAtPath:request.fileDownloadPath]) {
        DownLogModel *model = [[DownLogModel alloc] init];
        model.url = request.url;
        model.fileCachePath = request.fileCachePath;
        model.fileDownloadPath = request.fileDownloadPath;
        model.time = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
        model.state = DownOperationReadyState;
        
        if (model.fileDownloadPath.length > 0) {
            [self.downLogDict setObject:model forKey:[request getFileDownName]];
        }
        //存入本地
        [self storeDownLog];
        return YES;
    }
    
    return NO;
}

#pragma mark - 存储状态到日志
- (BOOL)addStateToDownLog:(NSString *)name state:(DownOperationState)state
{
    if (name.length > 0) {
        DownLogModel *model = [self.downLogDict objectForKey:name];
        if (nil != model) {
            model.state = state;
        }else {
            NSLog(@"addState_%@_对应模型查找失败",name);
        }
        [self storeDownLog];
        return YES;
    }
    return NO;
}

#pragma mark - 存储到本地
- (void)storeDownLog
{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, THREAD_STORE_FLAG), ^{
        @strongify(self);
        if (self.downLogDict.count > 0) {
            if (self.downHistoryPath.length > 0) {
                NSMutableDictionary *writeLog = [NSMutableDictionary dictionary];
                for (NSString *key in self.downLogDict.allKeys) {
                    NSError *error = nil;
                    DownLogModel *model = self.downLogDict[key];
                    NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:model error:&error];
                    if (!error && dict) {
                        [writeLog setObject:dict forKey:key];
                    }else {
                        NSLog(@"model转化dict-->%@",error);
                    }
                }
                
                if (writeLog.count > 0) {
                    OSSpinLockLock(&_storeLock);
                    [writeLog writeToURL:[NSURL fileURLWithPath:self.downHistoryPath] atomically:YES];
                    OSSpinLockUnlock(&_storeLock);
                }
            }
        }
    });
   
}

- (NSArray *)getAllBooksPaths
{
    if (self.downLogDict.count) {
        return self.downLogDict.allKeys;
    }
    return [NSArray array];
}

@end
