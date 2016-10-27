//
//  NSString+grep.h
//  pyd
//
//  Created by Wang Huiguang on 15/10/27.
//  Copyright © 2015年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString(grep)

+ (NSString *)stringWithSize:(long long)size;

- (BOOL)isStringForGrep:(NSString *)grep;

//根据网页链接获取下载文件的文件 全名、前名、后缀名
- (NSString *)getTotalName;
- (NSString *)getName;
- (NSString *)getExtendName;

@end
