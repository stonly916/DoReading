//
//  DRBaseTableViewController.h
//  DRBase
//
//  Created by Wang Huiguang on 16/5/27.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import "DRBaseViewController.h"

@interface DRBaseTableViewController : DRBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end
