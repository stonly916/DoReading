//
//  BookModel.h
//  DoReading
//
//  Created by Wang Huiguang on 15/11/27.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DRBookPositionState) {
    DRBookPositionNone = 0, //默认，没有打开过的小说
    DRBookPositionReading = 1,  //正在读的小说
    DRBookPositionLayDown = 2,   //读过，但不在书桌上的小说
    DRBookPositionDeleted = 3   //已被删除
};

@interface BookModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *bookName;
//需合并
@property (nonatomic, assign) NSTimeInterval lastOpenTime;
//需合并
@property (nonatomic, assign) NSUInteger bookMark;
//需合并
@property (nonatomic, assign) DRBookPositionState state;

@property (nonatomic, assign) long long bookSize;
//文件编码
@property (nonatomic, assign) NSUInteger encode;

@end
