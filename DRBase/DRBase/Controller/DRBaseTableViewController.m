//
//  DRBaseTableViewController.m
//  DRBase
//
//  Created by Wang Huiguang on 16/5/27.
//  Copyright © 2016年 forHappy. All rights reserved.
//

#import "DRBaseTableViewController.h"

@interface DRBaseTableViewController()



@end

@implementation DRBaseTableViewController

-(void)loadView
{
    [super loadView];
    self.tableView = [UITableView new];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = DR_COLOR_COMMON_BG;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UITableViewCell new];
}

@end
