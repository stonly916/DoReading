//
//  DRTabBarController.m
//  DoReading
//
//  Created by Wang Huiguang on 15/11/25.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import "DRTabBarController.h"

#import "DRHomeViewController.h"
#import "DRGetBookViewController.h"

@interface DRTabBarController ()

@end

@implementation DRTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = DR_COLOR_COMMON_BG;
    
    self.tabBar.translucent = NO;
    
    DRHomeViewController *homeVc = [[DRHomeViewController alloc] init];
    homeVc.title = @"读";
    DRNavigationController *homeNc = [[DRNavigationController alloc] initWithRootViewController:homeVc];
    homeNc.tabBarItem.image = [UIImage imageNamed:@"readBook"];
    
    DRGetBookViewController *getVc = [[DRGetBookViewController alloc] init];
    getVc.title = @"行";
    DRNavigationController *getNc = [[DRNavigationController alloc] initWithRootViewController:getVc];
    getNc.tabBarItem.image = [UIImage imageNamed:@"forReading"];
    
    self.viewControllers = @[homeNc, getNc];
    
}

@end
