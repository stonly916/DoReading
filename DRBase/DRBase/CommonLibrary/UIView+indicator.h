//
//  UIView+indicator.h
//  DRBase
//
//  Created by Wang Huiguang on 15/11/25.
//  Copyright © 2015年 forHappy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (indicator)
// 展示转标（立即展现）
- (void)showIndicator;

// 关闭转标（同时清除placeholder）
- (void)dismissIndicator;


// 展示Placeholder（独立接口）
- (void)showPlaceholder:(NSString *)title;

// 清除Placeholder（独立接口）
- (void)removePlaceholder;

@end
