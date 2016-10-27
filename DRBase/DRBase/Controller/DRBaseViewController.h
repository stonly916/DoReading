//
//  DRBaseViewController.h
//  DRBase
//
//  Created by Wang Huiguang on 15/11/27.
//  Copyright © 2015年 forHappy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRBaseViewController : UIViewController
//是否要用到键盘弹出事件
@property (nonatomic, assign) BOOL keyBoardWillShow;

- (void)shouldDoForKeyBoardWillShow:(CGFloat)height;
- (void)shouldDoForKeyBoardWillHide:(CGFloat)height;

@end
