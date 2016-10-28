//
//  UITextField+DRFactory.m
//  DRBase
//
//  Created by Wang Huiguang on 15/12/4.
//  Copyright © 2015年 forHappy. All rights reserved.
//

#import "UITextField+DRFactory.h"

@implementation UITextField (DRFactory)
+ (UITextField *)createWithfont:(UIFont *)font color:(UIColor *)textColor
{
    UITextField *t = [UITextField new];
    if (font) {
        t.font = font;
    }
    if (textColor) {
        t.textColor = textColor;
    }else {
        t.textColor = DR_COLOR_FONT_DARK;
    }
    
    t.layer.borderColor = [UIColor grayColor].CGColor;
    t.layer.borderWidth = .5f;
    t.layer.cornerRadius = 5.f;
    
    return t;
}
@end
