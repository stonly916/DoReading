//
//  UIButton+factory.m
//  DRBase
//
//  Created by Wang Huiguang on 16/10/27.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import "UIButton+factory.h"

@implementation UIButton (factory)

+ (UIButton *)createButton:(DRButtonType)type
{
    UIButton *btn;
    switch (type) {
        case DRButtonTypeDefault:
            btn = self.defaultType;
            break;
        default:
            btn = self.defaultType;
            break;
    }
    return btn;
}

+ (UIButton *)defaultType
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:DR_COLOR_FONT_DARK forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    [btn addEdgeColor:DR_COLOR_SEPARATOR];
    return btn;
}

- (void)addEdgeColor:(UIColor *)color
{
    self.layer.borderWidth = 0.3;
    self.layer.cornerRadius = 5.f;
    self.layer.borderColor = color.CGColor;
}

@end
