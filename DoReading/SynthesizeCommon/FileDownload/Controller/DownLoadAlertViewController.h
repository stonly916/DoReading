//
//  DownLoadAlertViewController.h
//  pyd
//
//  Created by Wang Huiguang on 15/11/2.
//  Copyright © 2015年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileDownloadManager.h"

@interface DownLoadAlertViewController : UIViewController

-(instancetype)initWithURL:(NSURL *)url useCache:(BOOL)useCache allowResume:(BOOL)allowResume;

- (void)showIn:(UIViewController *)viewController;

- (void)rasieWhenKeyboardShow:(CGFloat)height;
- (void)downWhenKeyboardHide:(CGFloat)height;
@end
