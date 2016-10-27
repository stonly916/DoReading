//
//  DRBookDeskTopViewCell.m
//  DoReading
//
//  Created by Wang Huiguang on 15/12/1.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import "DRBookDeskTopViewCell.h"

@interface DRBookDeskTopViewCell()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *sizeLabel;

@end

@implementation DRBookDeskTopViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    _titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 3;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.minimumScaleFactor = 10.f;
    _titleLabel.font = [UIFont systemFontOfSize:16.f];
    @weakify(self);
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.width.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(5);
    }];
    
    _sizeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_sizeLabel];
    _sizeLabel.textColor = DR_COLOR_CODE(@"#254a64");
    _sizeLabel.font = [UIFont systemFontOfSize:10.f];
    [_sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self.contentView).offset(-5);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];
}

-(void)setName:(NSString *)name size:(NSString *)size
{
    _titleLabel.text = name;
    _sizeLabel.text = size;
}

@end
