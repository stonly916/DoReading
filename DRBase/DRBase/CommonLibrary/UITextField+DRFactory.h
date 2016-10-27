//
//  UITextField+DRFactory.h
//  DRBase
//
//  Created by Wang Huiguang on 15/12/4.
//  Copyright © 2015年 forHappy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (DRFactory)
+ (UITextField *)createWithfont:(UIFont *)font color:(UIColor *)textColor;
@end
