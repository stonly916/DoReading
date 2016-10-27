//
//  FileDownloadRequest.h
//  pyd
//
//  Created by Wang Huiguang on 15/10/29.
//  Copyright © 2015年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadLog.h"

typedef void (^FileDownloadProgressBlock)(NSString *name, CGFloat progress);
typedef void (^FileDownloadCompletionBlock)(FileDownloadRequest *request, NSURL *filePath, NSError *error);
typedef void (^FileDownloadCompletionBlock_)(FileDownloadRequest *request, NSURL *filePath, BOOL hitCache, NSError *error);

//
// 文件下载请求
//
@interface FileDownloadRequest : NSObject

@property (nonatomic, strong, readonly) NSURL *url;
//下载状态
@property (nonatomic, assign, readonly) BOOL state;
@property (nonatomic, assign, readonly) NSTimeInterval timeout;
@property (nonatomic, strong, readonly) AFHTTPRequestOperation *operation;

@property (nonatomic, copy) NSString *fileCachePath;
@property (nonatomic, copy) NSString *fileDownloadPath;
/*
 *url:请求链接
 *timeout:超时时间
 *priorty:优先级
 *useCache:使用缓存
 *allowResume:断点续传
 *progresBlock:进度
 *completionBlock:完成调用
*/
+ (FileDownloadRequest *)downloadRequestWithURL:(NSURL *)url
                                           name:(NSString *)name
                                        timeout:(NSTimeInterval)timeout
                                       priority:(NSOperationQueuePriority)priority
                                       useCache:(BOOL)useCache
                                    allowResume:(BOOL)allowResume
                                  progressBlock:(FileDownloadProgressBlock)progresBlock
                                completionBlock:(FileDownloadCompletionBlock_)completionBlock;
//设置新的文件名
- (void)setFileDownName:(NSString *)newName;

//获得下载后的文件名
- (NSString *)getFileDownName;

@end