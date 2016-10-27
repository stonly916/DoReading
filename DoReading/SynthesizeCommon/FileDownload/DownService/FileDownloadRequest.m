//
//  FileDownloadRequest.m
//  pyd
//
//  Created by Wang Huiguang on 15/10/29.
//  Copyright © 2015年 iOS. All rights reserved.
//

#import "FileDownloadRequest.h"


void * const FileDownloadRequestOperationContext = @"FileDownloadRequestOperationContext";

@interface FileDownloadRequest ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *extendName;

@property (nonatomic, assign, readwrite) NSTimeInterval timeout;
@property (nonatomic, strong, readwrite) AFHTTPRequestOperation *operation;

@property (nonatomic, assign) BOOL useCache;
@property (nonatomic, assign) BOOL allowResume;

- (void)fetchItemFromCacheWithProgressBlock:(FileDownloadProgressBlock)progressBlock
                 completionBlock:(FileDownloadCompletionBlock_)completionBlock;

+ (NSURLRequest *)urlRequestWithURL:(NSURL *)url
                            timeout:(NSTimeInterval)timeout
                        allowResume:(BOOL)allowResume
                   fileDownloadPath:(NSString *)fileDownloadPath;

+ (BOOL)hasCacheForPath:(NSString *)path;
@end

@implementation FileDownloadRequest

+ (FileDownloadRequest *)downloadRequestWithURL:(NSURL *)url
                                           name:(NSString *)name
                                        timeout:(NSTimeInterval)timeout
                                       priority:(NSOperationQueuePriority)priority
                                       useCache:(BOOL)useCache
                                    allowResume:(BOOL)allowResume
                                  progressBlock:(FileDownloadProgressBlock)progresBlock
                                completionBlock:(FileDownloadCompletionBlock_)completionBlock
{
    FileDownloadRequest *request = [FileDownloadRequest new];
    
    DownloadLog *downlog = [DownloadLog sharedInstance];
    
    request.url = url;
    request.name = name;
    NSString *extendName = [name getExtendName];
    request.extendName = extendName;
    
    request.timeout = timeout;
    request.useCache = useCache;
    request.allowResume = allowResume;
    request.fileCachePath = [downlog getCachePathWith:name];
    request.fileDownloadPath = [downlog getDownPathWith:name];
    
    // 使用如果文件下载
    if (useCache && [self hasCacheForPath:request.fileDownloadPath]) {
        [request fetchItemFromCacheWithProgressBlock:progresBlock
                          completionBlock:completionBlock];
        return nil;
    }
    
    // 重新下载文件
    NSURLRequest *urlRequest = [self urlRequestWithURL:url
                                               timeout:timeout
                                           allowResume:allowResume
                                      fileDownloadPath:request.fileCachePath];
    request.operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    request.operation.outputStream = [NSOutputStream outputStreamToFileAtPath:request.fileCachePath append:YES];
    request.operation.queuePriority = priority;
    // KVO
    [request.operation addObserver:request
                        forKeyPath:@keypath2(request.operation, isExecuting)
                           options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                           context:FileDownloadRequestOperationContext];
//
    @weakify(request);
    [request.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        @strongify(request);
        CGFloat progress;
        if (totalBytesExpectedToRead == -1) {
            progress = -1;
        } else {
            progress = (CGFloat)totalBytesRead / (CGFloat)totalBytesExpectedToRead;
        }
        progresBlock(request.name, progress);
    }];
    
    [request.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(request);
        [CFileHandle removeFileAtPath:request.fileDownloadPath];
        [CFileHandle moveItemAtPath:request.fileCachePath toPath:request.fileDownloadPath];
        completionBlock(request, [NSURL fileURLWithPath:request.fileDownloadPath], NO, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(request);
        completionBlock(request, nil, NO, error);
    }];
    
    return request;
}

- (void)setFileDownName:(NSString *)newName
{
    self.name = newName;
    self.fileCachePath = [[DownloadLog sharedInstance] getCachePathWith:newName];
    self.fileDownloadPath = [[DownloadLog sharedInstance] getDownPathWith:newName];
    self.operation.outputStream = [NSOutputStream outputStreamToFileAtPath:self.fileCachePath append:YES];
}

//获得下载后的文件名
- (NSString *)getFileDownName
{
    if (![[self.fileDownloadPath getTotalName] isEqualToString:self.name]){
        self.name = [self.fileDownloadPath getTotalName];
    }
    return self.name;
}

// KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != FileDownloadRequestOperationContext) {
        if ([[self superclass] instancesRespondToSelector:_cmd]) {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        return;
    }
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(isExecuting))]) {
        if ([object isKindOfClass:[NSOperation class]]) {
            NSOperation *operation = (NSOperation *)object;
            if (operation.isExecuting) {
                if (!self.allowResume) {
                    // 下载开始前删除临时文件
                    [CFileHandle removeFileAtPath:self.fileCachePath];
                }
                [operation removeObserver:self
                               forKeyPath:@keypath2(operation, isExecuting)
                                  context:FileDownloadRequestOperationContext];
            }
        }
    }
}

// 是否存在已下载文件
+ (BOOL)hasCacheForPath:(NSString *)path
{
    return [CFileHandle containFileAtPath:path];
}

// 直接使用已下载文件
- (void)fetchItemFromCacheWithProgressBlock:(FileDownloadProgressBlock)progressBlock
                 completionBlock:(FileDownloadCompletionBlock_)completionBlock
{
    NSString *name = self.name;
    NSString *fileDownloadPath = self.fileDownloadPath;
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            progressBlock(name, 1.f);
            completionBlock(self, [NSURL fileURLWithPath:fileDownloadPath], YES, nil);
        });
    });
}

// 创建URLRequest
+ (NSURLRequest *)urlRequestWithURL:(NSURL *)url
                            timeout:(NSTimeInterval)timeout
                        allowResume:(BOOL)allowResume
                   fileDownloadPath:(NSString *)fileDownloadPath;
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:timeout];
    //
    // 允许断点续传（需要服务器支持）
    //
    if (allowResume) {
        // 检查已下载部分的字节
        unsigned long long downloadedBytes = 0;
        if ([CFileHandle containFileAtPath:fileDownloadPath]) {
            downloadedBytes = [CFileHandle getFileSize:fileDownloadPath];
            if (downloadedBytes) {
                NSMutableURLRequest *mutableURLRequest = [urlRequest mutableCopy];
                NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
                [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
                
                urlRequest = mutableURLRequest;
            }
        }
    } else {
        // 删除临时文件
        [CFileHandle removeFileAtPath:fileDownloadPath];
    }
    
    // 不使用HTTP缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:urlRequest];
    
    return urlRequest;
}

@end
