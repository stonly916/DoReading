//
//  UIView+indicator.m
//  DRBase
//
//  Created by Wang Huiguang on 15/11/25.
//  Copyright © 2015年 forHappy. All rights reserved.
//

#import "UIView+indicator.h"

@implementation UIView (indicator)

- (UIView *)createIndicatorView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CALayer *back = [[CALayer alloc] init];
    back.frame = CGRectMake((width-60)/2, (height-60)/2, 60, 60);
    back.backgroundColor = [UIColor blackColor].CGColor;
    back.cornerRadius = 7.f;
    back.opacity = 0.5;
    
    CALayer *indicator = [[CALayer alloc] init];
    indicator.frame = CGRectMake(7.5, 7.5, 45, 45);
    UIImage *image = [UIImage imageNamed:@"load_login"];
    indicator.contents = (__bridge id)image.CGImage;
    indicator.contentsGravity =  kCAGravityResizeAspectFill;
    [back addSublayer:indicator];
    [self addAnimationTo:indicator];
    
    UIView *cover = [[UIView alloc] init];
    cover.frame = [UIScreen mainScreen].bounds;
    cover.backgroundColor = [UIColor clearColor];
    [cover.layer addSublayer:back];
    return cover;
}

- (void)addAnimationTo:(CALayer *)indicator
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];

    anim.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    anim.duration = 1.12f;
    anim.cumulative = YES;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeBoth;
    anim.repeatCount = CGFLOAT_MAX;
    [indicator addAnimation:anim forKey:@"rotation.z"];
}

// 展示转标（立即展现）
- (void)showIndicator
{
    self.indicator = [self createIndicatorView];
    
    [[UIApplication sharedApplication].windows.firstObject addSubview:self.indicator];
}

// 关闭转标（同时清除placeholder）
- (void)dismissIndicator
{
    [self.indicator removeFromSuperview];
}

// 展示Placeholder（独立接口）
- (void)showPlaceholder:(NSString *)title
{
    
}

// 清除Placeholder（独立接口）
- (void)removePlaceholder
{
    
}

#pragma mark - objc_setAssociatedObject & objc_getAssociatedObject

- (id)indicator
{
    return objc_getAssociatedObject(self, @selector(indicator));
}

- (void)setIndicator:(UIView *)indicator
{
    objc_setAssociatedObject(self, @selector(indicator), indicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
