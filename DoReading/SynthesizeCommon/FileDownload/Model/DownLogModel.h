//
//  DownLogModel.h
//  DoReading
//
//  Created by Wang Huiguang on 15/10/30.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

typedef NS_ENUM(NSInteger, DownOperationState) {
    DownOperationPausedState      = -1,
    DownOperationUnkown           = 0,
    DownOperationReadyState       = 1,
    DownOperationExecutingState   = 2,
    DownOperationFinishedState    = 3,
};

@interface DownLogModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, retain) NSNumber *time;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) NSString *fileCachePath;
@property (nonatomic, copy) NSString *fileDownloadPath;
@property (nonatomic, assign) DownOperationState state;

@end