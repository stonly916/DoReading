//
//  DRAddLocationViewController.m
//  DoReading
//
//  Created by Wang Huiguang on 15/11/30.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import "DRAddLocationViewController.h"

@interface DRAddLocationViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *booksArray;

@property (nonatomic, strong) NSMutableArray *selectedBooks;

@property (nonatomic, strong) UIView *cover;
@end

@implementation DRAddLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"导入本地书籍";
    
    _booksArray = [NSArray array];
    _selectedBooks = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [UIView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.editing = YES;
    [self rightBarItem];
    
    [self getBooks];
}

- (void)rightBarItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarItemClick:)];
}

- (void)rightBarItemClick:(UIBarButtonItem *)item
{
    self.getBookModel(_selectedBooks);
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showNoneBooksView
{
    if (_cover == nil) {
        _cover = [[UIView alloc] initWithFrame:self.view.bounds];
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:16];
        label.text = @"本地无可添加书籍";
        [_cover addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_cover);
            make.centerY.equalTo(_cover).offset(-35);
        }];
        
        UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        refreshBtn.layer.borderColor = DR_COLOR_FONT_COOL.CGColor;
        refreshBtn.layer.borderWidth = 1.f;
        refreshBtn.layer.cornerRadius = 5.f;
        [refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
        [refreshBtn addTarget:self action:@selector(refreshBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_cover addSubview:refreshBtn];
        [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(label);
            make.width.equalTo(@75);
            make.top.equalTo(label.mas_bottom).offset(5);
        }];
    }
    
    [self.view addSubview:_cover];
}

- (void)refreshBtnClick:(UIButton *)btn
{
    if (_cover) {
        [_cover removeFromSuperview];
    }
    [self getBooks];
}

- (void)getBooks
{
    @weakify(self);
    [BooksManager booksInLocationUpdateExpectDeskWithArray:^(NSArray *array) {
        @strongify(self);
        if (array.count > 0) {
            self.booksArray = array;
            [self.tableView reloadData];
        }else {
            [self showNoneBooksView];
        }
    }];
}

#pragma mark - UITableViewDateSource UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.booksArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationBook"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"locationBook"];
    }
    
    BookModel *model = self.booksArray[indexPath.row];
    cell.textLabel.text = model.bookName;
    cell.detailTextLabel.text = [NSString stringWithSize:model.bookSize];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert);

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookModel *model = self.booksArray[indexPath.row];
    if ([self.selectedBooks containsObject:model]) {
       [self.selectedBooks removeObject:model];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookModel *model = self.booksArray[indexPath.row];
    if (![self.selectedBooks containsObject:model]) {
        [self.selectedBooks addObject:model];
    }
}

@end
