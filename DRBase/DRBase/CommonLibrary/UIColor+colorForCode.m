//
//  UIColor+colorForCode.m
//  DRBase
//
//  Created by Wang Huiguang on 16/10/27.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import "UIColor+colorForCode.h"

@implementation UIColor (colorForCode)

/**
 * 根据颜色代码值生成Color
 * @param colorCode 颜色代码<br>
 *              dcdcdc: r:dc, g:dc, b:dc<br>
 *              #dcdcdc: r:dc, g:dc, b:dc<br>
 *              ffdcdcdc: a:ff, r:dc, g:dc, b:dc<br>
 *              #ffdcdcdc: a:ff, r:dc, g:dc, b:dc<br>
 *              fdcdcdc: a:f, r:dc, g:dc, b:dc<br>
 *              #fdcdcdc: a:f, r:dc, g:dc, b:dc<br>
 */
+ (UIColor *)colorWithCode:(NSString *)colorCode {
    NSString *cString = [[colorCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];//字符串处理
    
    //例子，stringToConvert #ffffff
    if ([cString length] < 6)
        return nil;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];//去掉头
    if ([cString length] > 8)//去头非十六进制，返回白色
        return nil;
    
    //分别取ARGB的值
    NSRange range;
    range.location = 0;
    range.length = 0;
    
    NSString *aString = @"ff";
    if (cString.length > 6) {
        range.length = (cString.length==7)? 1 : 2;
        aString = [cString substringWithRange:range];
    }
    
    range.location = range.length;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location += 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location += 2;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int a, r, g, b;
    //NSScanner把扫描出的制定的字符串转换成Int类型
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    //转换为UIColor
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:((float) a / 255.0f)];
}

@end
