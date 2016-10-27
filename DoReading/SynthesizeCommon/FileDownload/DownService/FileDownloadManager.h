//
//  FileDownloadManager.h
//  pyd
//
//  Created by Wang Huiguang on 15/10/29.
//  Copyright © 2015年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownloadRequest.h"

@interface FileDownloadManager : NSObject
// 单例
+ (FileDownloadManager *)sharedInstance;

// 文件下载超时时间
@property (nonatomic, assign) NSTimeInterval timeout;
// 文件最大下载数
@property (nonatomic, assign) NSUInteger maxConCurrent;

- (void)downloadFileWithURL:(NSURL *)url
            completionBlock:(FileDownloadCompletionBlock)completionBlock;

- (void)downloadFileWithURL:(NSURL *)url
                       name:(NSString *)name
            completionBlock:(FileDownloadCompletionBlock)completionBlock;

- (void)downloadFileWithURL:(NSURL *)url
                       name:(NSString *)name
                   useCache:(BOOL)useCache
            completionBlock:(FileDownloadCompletionBlock)completionBlock;

- (void)downloadFileWithURL:(NSURL *)url
                       name:(NSString *)name
                   useCache:(BOOL)useCache
              progressBlock:(FileDownloadProgressBlock)progresBlock
            completionBlock:(FileDownloadCompletionBlock)completionBlock;

- (void)downloadFileWithURL:(NSURL *)url
                       name:(NSString *)name
                   priority:(NSOperationQueuePriority)priority
                   useCache:(BOOL)useCache
                allowResume:(BOOL)allowResume
              progressBlock:(FileDownloadProgressBlock)progresBlock
            completionBlock:(FileDownloadCompletionBlock)completionBlock;

// 取消下载
- (void)cancelDownloadFileWithURL:(NSURL *)url;
@end
