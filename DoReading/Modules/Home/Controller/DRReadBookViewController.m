//
//  DRReadBookViewController.m
//  DoReading
//
//  Created by Wang Huiguang on 15/12/2.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import "DRReadBookViewController.h"
#import "DRReadView.h"
#import "DRBookSet.h"

@interface DRReadBookViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) BookModel *deskBookModel;

@property (nonatomic, strong) NSArray *bookRangeArray;

//书籍内容
@property (nonatomic, copy) NSString *bookContent;

@property (nonatomic, strong) DRReadView *readView;

//设置View
@property (nonatomic, strong) UIView *setView;
//覆盖View
@property (nonatomic, strong) UIView *coverView;
//底部
@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) UITapGestureRecognizer *tap;



@property (nonatomic, strong) NSMutableDictionary *settingInfo;

@property (nonatomic, strong) UITextField *progressField;

@end

@implementation DRReadBookViewController

- (void)loadReadViewControllerWith:(BookModel *)deskBookModel
{
    _deskBookModel = deskBookModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.deskBookModel.bookName;
    self.view.backgroundColor = COLOR_BOOK_ORANGE;
    

    [self createBottomView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStyleDone target:self action:@selector(settingItemClick:)];

    @weakify(self);
    [self.view showIndicator];
    [BooksManager bookDateForLocatin:self.deskBookModel.bookName completed:^(NSData *data, NSStringEncoding encode, NSError *error) {
        @strongify(self);
        [self.view dismissIndicator];
        if (data == nil && error == nil) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"此书已被删除" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:sureAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }else {
            NSString *str = [[NSString alloc] initWithData:data encoding:encode];
            [self initReadView:str];
        }
    }];
}

- (void)createBottomView
{
    UIView *bottomView = [[UIView alloc] init];
    [self.view addSubview:bottomView];
    @weakify(self);
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@20);
        make.width.equalTo(self.view);
    }];
    _rateLabel = [UILabel createWithfont:[UIFont systemFontOfSize:10.f] color:[UIColor whiteColor] text:@"0.00%"];
    [bottomView addSubview:_rateLabel];
    [_rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomView);
        make.height.equalTo(bottomView);
        make.right.equalTo(bottomView).offset(-5);
    }];
}

#pragma  mark - 
- (void)initReadView:(NSString *)string
{
    self.readView = [[DRReadView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.width, [UIScreen mainScreen].bounds.size.height - 64 - 20) text:string];
    @weakify(self);
    self.readView.finishRoll = ^(NSInteger position){
        @strongify(self);
        [self bookFinishedRoll:position];
    };
    [self.readView rollPageToPostion:self.deskBookModel.bookMark];
    [self.view addSubview:self.readView];
}

#pragma mark - 设置选项
- (void)settingItemClick:(UIBarButtonItem *)item
{
    if (nil == _setView) {
        _setView = [[UIView alloc] initWithFrame:CGRectMake(0, -100, self.view.width, 100)];
        _setView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        
        UILabel *progressLabel = [UILabel createWithfont:nil color:nil text:@"进度"];
        [_setView addSubview:progressLabel];
        [progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.top.equalTo(_setView).offset(5);
        }];
        
        _progressField = [UITextField createWithfont:DR_FONT_L3 color:nil];
        _progressField.delegate = self;
        _progressField.keyboardType = UIKeyboardTypeDecimalPad;
        _progressField.borderStyle = UITextBorderStyleRoundedRect;
        _progressField.placeholder = @"0 ~ 100";
        [_setView addSubview:_progressField];
        [_progressField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(progressLabel);
            make.right.equalTo(_setView).offset(-15);
            make.width.equalTo(@100);
            make.height.equalTo(@30);
        }];
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sureBtn setBackgroundImage:[UIImage imageNamed:@"round_dot"] forState:UIControlStateNormal];
        [_setView addSubview:sureBtn];
        [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_setView);
            make.bottom.equalTo(_setView).offset(-3);
            make.width.height.equalTo(@30);
        }];
        [sureBtn addTarget:self action:@selector(setSureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    _progressField.text = nil;
    if (nil == _coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.view.bounds];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0.2;
        if (nil == _tap) {
            _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeCover)];
        }
        [_coverView addGestureRecognizer:_tap];
    }
    
    if (_setView.superview && _coverView.superview) {
        [self removeCover];
    }else {
        [self.view addSubview:_coverView];
        [self.view addSubview:_setView];
        [self animationWithSetView:100.f complete:nil];
    }
}
- (void)animationWithSetView:(CGFloat)height complete:(void(^)())complete
{
    [UIView animateWithDuration:0.25f animations:^{
        _setView.transform = CGAffineTransformMakeTranslation(0, height);
    } completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
    }];
}

- (void)removeCover
{
    [self animationWithSetView:0 complete:^{
        [self.coverView removeFromSuperview];
        [self.setView removeFromSuperview];
    }];
}

#pragma mark - 设置按钮点击确定
- (void)setSureBtnClick:(UIButton *)btn
{
    NSString *progress = _progressField.text;
    [self.readView rollPageToPercent:progress.floatValue/100.f];
    [self removeCover];
}
#pragma mark - UITextFiledDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isStringForGrep:@"[0-9.]*"]) {
        NSString *str = @"";
        str = [str stringByAppendingString:textField.text];
        str = [str stringByAppendingString:string];
        if ([str isStringForGrep:@"[0-9]*.{0,1}[0-9]*"]) {
            return YES;
        }
    }
    return NO;
}


//翻页后存储
- (void)bookFinishedRoll:(NSInteger)position
{
    self.deskBookModel.bookMark = position;
    NSString *str = [NSString stringWithFormat:@"%.2f%%",self.readView.bookSetter.rate];
    self.rateLabel.text = str;
    [BooksManager storeDeskLog];
}

@end
