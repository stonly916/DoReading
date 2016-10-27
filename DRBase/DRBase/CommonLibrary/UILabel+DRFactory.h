//
//  UILabel+DRFactory.h
//  DRBase
//
//  Created by Wang Huiguang on 15/12/4.
//  Copyright © 2015年 forHappy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (DRFactory)
+ (UILabel *)createWithfont:(UIFont *)font color:(UIColor *)textColor text:(NSString *)text;
@end
