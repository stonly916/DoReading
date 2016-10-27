//
//  DownloadLog.h
//  pyd
//
//  Created by Wang Huiguang on 15/10/29.
//  Copyright © 2015年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "DownLogModel.h"

@class FileDownloadRequest;

@interface DownloadLog : NSObject
@property (nonatomic, copy, readonly) NSString *fileDownloaderDirectory;
@property (nonatomic, copy, readonly) NSString *fileStoreDirectory;
@property (nonatomic, copy, readonly) NSString *downHistoryPath;

+(instancetype)sharedInstance;

- (NSString *)getCachePathWith:(NSString *)name;
- (NSString *)getDownPathWith:(NSString *)name;

- (BOOL)addToDownLog:(FileDownloadRequest *)request;
- (BOOL)addStateToDownLog:(NSString *)fileDownloadPath state:(DownOperationState)state;
- (BOOL)addProgressToDownLog:(CGFloat)progress byName:(NSString *)name;
@end
