//
//  DRBaseViewController.m
//  DRBase
//
//  Created by Wang Huiguang on 15/11/27.
//  Copyright © 2015年 forHappy. All rights reserved.
//

#import "DRBaseViewController.h"

@interface DRBaseViewController ()

@end

@implementation DRBaseViewController

-(void)loadView
{
    [super loadView];
    _keyBoardWillShow = NO;
    if (self.navigationController) {
        CGRect rect = self.view.frame;
        rect.size.height -= 64;
        self.view.frame = rect;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = DR_COLOR_COMMON_BG;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_keyBoardWillShow) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_keyBoardWillShow) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}


- (void)shouldDoForKeyBoardWillShow:(CGFloat)height
{
    //子类必须实现的方法
}
- (void)shouldDoForKeyBoardWillHide:(CGFloat)height
{
    //子类必须实现的方法
}

- (void)keyBoardWillShow:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    CGSize keyboardSize = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = keyboardSize.height;
    
    if ([self respondsToSelector:@selector(shouldDoForKeyBoardWillShow:)]) {
        [self shouldDoForKeyBoardWillShow:height];
    }
}

- (void)keyBoardWillHide:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    CGSize keyboardSize = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = keyboardSize.height;
    
    if ([self respondsToSelector:@selector(shouldDoForKeyBoardWillHide:)]) {
        [self shouldDoForKeyBoardWillHide:height];
    }
}

@end
