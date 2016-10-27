//
//  DownLoadAlertViewController.m
//  pyd
//
//  Created by Wang Huiguang on 15/11/2.
//  Copyright © 2015年 iOS. All rights reserved.
//

#import "DownLoadAlertViewController.h"
#import "FileDownloadManager.h"

#define DOWNALERT_HEIGHT 200.f

@interface DownLoadAlertViewController ()
//parentViewController
@property (nonatomic, strong) UIViewController *parentVc;

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, assign) BOOL useCache;

@property (nonatomic, assign) BOOL allowResume;
//暗色背景
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
//提示框
@property (nonatomic, strong) UIView *backView;
//下载提示
@property (nonatomic, strong) UILabel *downToast;
//文件名
@property (nonatomic, strong) UITextField *fileNameText;
//下载地址
@property (nonatomic, strong) UITextField *urlText;

@property (nonatomic ,strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *downSureButton;
@property (nonatomic, strong) UIButton *editButton;


@end

@implementation DownLoadAlertViewController

-(instancetype)initWithURL:(NSURL *)url useCache:(BOOL)useCache allowResume:(BOOL)allowResume
{
    if (self = [super init]) {
        _url = url;
        _fileName = [[url absoluteString] getTotalName];
        _useCache = useCache;
        _allowResume = allowResume;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.coverView.backgroundColor = [UIColor blackColor];
    self.coverView.alpha = 0.2;
    [self.view addSubview:self.coverView];
    
    [self createUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 键盘通知处理
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // 移除键盘通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 显示下载的上拉弹窗
- (void)showIn:(UIViewController *)viewController
{
    _parentVc = viewController;
    [viewController addChildViewController:self];
    [viewController.view addSubview:self.view];
    
    [self animationWithBackViewTransform:-DOWNALERT_HEIGHT completion:^{
        [self addGesture];
    }];
}

- (void)rasieWhenKeyboardShow:(CGFloat)height
{
    if (self.parentVc) {
        if (nil != self.parentVc.tabBarController) {
            height -= self.parentVc.tabBarController.tabBar.height;
        }
        [self animationWithBackViewTransform:-height-DOWNALERT_HEIGHT completion:nil];
    }
}

- (void)downWhenKeyboardHide:(CGFloat)height
{
    if (self.parentVc) {
        [self animationWithBackViewTransform:-DOWNALERT_HEIGHT completion:nil];
    }
}
#pragma mark - 动画处理
- (void)animationWithBackViewTransform:(CGFloat)height completion:(void(^)())block
{
    [UIView animateWithDuration:0.25 animations:^{
        self.backView.transform = CGAffineTransformMakeTranslation(0, height);
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
    }];
}

- (void)addGesture
{
    if (nil == self.tap) {
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuper)];
    }
    [self.coverView addGestureRecognizer:self.tap];
}

#pragma mark - 移除下载的上拉弹窗
- (void)removeFromSuper
{
    self.parentVc = nil;
    [self animationWithBackViewTransform:0 completion:^{
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }];
}

- (void)createUI
{
    CGFloat height = 0.f;
    if (_parentVc.tabBarController && !_parentVc.tabBarController.tabBar.hidden) {
        height = _parentVc.tabBarController.tabBar.height;
    }
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 49, SCREEN_WIDTH, DOWNALERT_HEIGHT)];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backView];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 48)];
    [self.backView addSubview:topView];
    
    //取消按钮
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [topView addSubview:self.cancelButton];
    self.cancelButton.frame = CGRectMake(10, 10, 50, 28);
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];//23	152	185
    [self.cancelButton setTitleColor:DR_COLOR_FONT_COOL forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //下载提示
    self.downToast = [[UILabel alloc] initWithFrame:CGRectMake(self.cancelButton.top + self.cancelButton.width + 5, 10, SCREEN_WIDTH - 10 - self.cancelButton.width * 2 - 20, 28)];
    self.downToast.font = [UIFont systemFontOfSize:14];
    self.downToast.text = [NSString stringWithFormat:@"下载文件:%@",[[self.url absoluteString] getTotalName]];
    [topView addSubview:self.downToast];
    
    //编辑按钮
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.frame = CGRectMake(SCREEN_WIDTH - 60, 10, 50, 28);
    [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [self.editButton setTitle:@"完成" forState:UIControlStateSelected];
    self.editButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.editButton setTitleColor:DR_COLOR_FONT_COOL forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:self.editButton];
    
    UILabel *fileLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, topView.height + 10, 45, 32)];
    fileLabel.font = [UIFont systemFontOfSize:16];
    fileLabel.text = @"文件:";
    [self.backView addSubview:fileLabel];
    //下载文件名
    self.fileNameText = [[UITextField alloc] initWithFrame:CGRectMake(fileLabel.left + fileLabel.width, fileLabel.top, SCREEN_WIDTH - fileLabel.width - 20, 32)];
    self.fileNameText.backgroundColor = [UIColor clearColor];
    self.fileNameText.borderStyle = UITextBorderStyleNone;
    self.fileNameText.enabled= NO;
    self.fileNameText.text = [[self.url absoluteString] getTotalName];
    [self.backView addSubview:self.fileNameText];
    self.fileNameText.font = [UIFont systemFontOfSize:16];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, fileLabel.top + fileLabel.height + 10, 45, 32)];
    addressLabel.font = [UIFont systemFontOfSize:16];
    addressLabel.text = @"URL:";
    [self.backView addSubview:addressLabel];
    //下载文件地址
    self.urlText = [[UITextField alloc] initWithFrame:CGRectMake(addressLabel.left + addressLabel.width, addressLabel.top, SCREEN_WIDTH - addressLabel.width - 20, 32)];
    self.urlText.backgroundColor = [UIColor clearColor];
    self.urlText.borderStyle = UITextBorderStyleRoundedRect;
    self.urlText.enabled= NO;
    self.urlText.text = [self.url absoluteString];
    [self.backView addSubview:self.urlText];
    self.urlText.font = [UIFont systemFontOfSize:16];
    
    //下载确认按钮
    self.downSureButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backView addSubview:self.downSureButton];
    [self.downSureButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    CGFloat totalHeight = self.backView.height - addressLabel.top - addressLabel.height;
    [self.downSureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(topView);
        make.bottom.equalTo(self.backView).offset(-0.15 * totalHeight);
        make.top.equalTo(addressLabel.mas_bottom).offset(0.15 * totalHeight);
        make.width.equalTo(@(0.82 * SCREEN_WIDTH));
    }];
    
    [self.downSureButton setTitle:@"下载" forState:UIControlStateNormal];
    self.downSureButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.downSureButton.layer.borderColor = DR_COLOR_FONT_COOL.CGColor;
    self.downSureButton.layer.borderWidth = 0.5;
    self.downSureButton.layer.cornerRadius = 6;
    [self.downSureButton addTarget:self action:@selector(downSureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)cancelButtonClick:(UIButton *)btn
{
    [self removeFromSuper];
}

- (void)editButtonClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        self.fileNameText.enabled = YES;
        self.fileNameText.borderStyle = UITextBorderStyleRoundedRect;
        self.urlText.enabled = YES;
        self.downSureButton.enabled = NO;
    }else {
        self.fileNameText.borderStyle = UITextBorderStyleNone;
        self.fileNameText.enabled = NO;
        self.fileName = self.fileNameText.text;
        
        self.urlText.enabled = NO;
        self.url = [NSURL URLWithString:self.urlText.text];
        
        self.downSureButton.enabled = YES;
    }
}

- (void)downSureButtonClick:(UIButton *)btn
{
    [[FileDownloadManager sharedInstance] downloadFileWithURL:self.url name:self.fileName priority:NSOperationQueuePriorityNormal useCache:self.useCache allowResume:self.allowResume progressBlock:^(NSString *name, CGFloat progress) {
        
    } completionBlock:^(FileDownloadRequest *request, NSURL *filePath, NSError *error) {
        
    }];
    [self removeFromSuper];
}

#pragma mark - Keyboard notifications


- (void)keyboardWillShow:(NSNotification *)notification
{
    
    NSDictionary *dict = [notification userInfo];
    CGSize keyboardSize = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat height = DOWNALERT_HEIGHT;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        height += (keyboardSize.height);
    } else {
        height += (keyboardSize.width);
    }
    [self animationWithBackViewTransform:-height completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self animationWithBackViewTransform:-DOWNALERT_HEIGHT completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
