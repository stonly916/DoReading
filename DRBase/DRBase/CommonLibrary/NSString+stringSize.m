//
//  NSString+stringSize.m
//  DRBase
//
//  Created by Wang Huiguang on 16/5/26.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import "NSString+stringSize.h"

@implementation NSString (stringSize)

- (CGSize)sizeForAtrributes:(NSDictionary *)atrr width:(CGFloat)width
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
    return rect.size;
}

@end
