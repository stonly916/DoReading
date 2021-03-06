//
//  DRNavigationController.m
//  DRBase
//
//  Created by Wang Huiguang on 15/11/25.
//  Copyright © 2015年 forHappy. All rights reserved.
//

#import "DRNavigationController.h"

@interface DRNavigationController ()

@end

@implementation DRNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationBar.backgroundColor = DR_COLOR_COMMON_BLUE;
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = DR_COLOR_COMMON_BLUE;
    self.navigationBar.translucent = NO;
    
    [self.navigationBar setShadowImage:[UIImage new]];
}

@end
