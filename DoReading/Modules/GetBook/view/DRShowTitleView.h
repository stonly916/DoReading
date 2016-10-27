//
//  DRShowTitleView.h
//  DoReading
//
//  Created by Wang Huiguang on 16/5/26.
//  Copyright © 2016年 ForHappy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRShowTitleView : UIControl

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIImageView *imageView;

-(instancetype)initWithFrame:(CGRect)frame;

- (void)upOrDown;

@end
