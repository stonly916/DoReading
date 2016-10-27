//
//  DRShowTitleView.m
//  DoReading
//
//  Created by Wang Huiguang on 16/5/26.
//  Copyright © 2016年 ForHappy. All rights reserved.
//

#import "DRShowTitleView.h"

#define IMAGE_WIDTH 13.f

@interface DRShowTitleView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) BOOL up;

@end

@implementation DRShowTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 100, 40)]) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    _titleLabel = [UILabel createWithfont:DR_FONT_L1 color:[UIColor blackColor] text:self.title];
    [self addSubview:_titleLabel];
    @weakify(self);
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self);
        make.centerX.equalTo(self).offset(-IMAGE_WIDTH/2.0);
    }];
    
    _imageView = [UIImageView new];
    _imageView.image = [UIImage imageNamed:@"arrow_down"];
    [self addSubview:_imageView];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self);
        make.bottom.equalTo(_titleLabel);
        make.height.mas_equalTo(7);
        make.width.mas_equalTo(IMAGE_WIDTH);
    }];
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI);
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    self.width = [title sizeForAtrributes:@{NSFontAttributeName:DR_FONT_L1} width:CGFLOAT_MAX].width + IMAGE_WIDTH;
}

- (void)upOrDown
{
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI);
    }];
}

@end
