//
//  UILabel+DRFactory.m
//  DRBase
//
//  Created by Wang Huiguang on 15/12/4.
//  Copyright © 2015年 forHappy. All rights reserved.
//

#import "UILabel+DRFactory.h"

@implementation UILabel (DRFactory)

+ (UILabel *)createWithfont:(UIFont *)font color:(UIColor *)textColor text:(NSString *)text
{
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    if (font) {
        label.font = font;
    }
    if (textColor) {
        label.textColor = textColor;
    }
    if (text) {
        label.text = text;
    }
    return label;
}

@end
