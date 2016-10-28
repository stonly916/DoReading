//
//  DRSetViewController.m
//  DoReading
//
//  Created by Wang Huiguang on 16/5/27.
//  Copyright © 2016年 ForHappy. All rights reserved.
//

#import "DRSetViewController.h"
#import "DRBookSchemeUrl.h"

@interface DRSetViewController()<UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *urlArray;

@property (nonatomic, strong) UITextField *inputField;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@end

@implementation DRSetViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.keyBoardWillShow = YES;
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    
    [self initUrlArray];
}

- (void)closeKeyboard
{
    [self.view endEditing:YES];
}

- (void)initUrlArray
{
    _titleArray = [NSMutableArray array];
    _urlArray = [NSMutableArray array];

    for (BookWebInfoModel *model in share(DRBookSchemeUrl).bookWebList) {
        [self.titleArray DRAddObject:DR_NONNULL_STRING(model.webName)];
        [self.urlArray DRAddObject:DR_NONNULL_STRING(model.baseUrl)];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else {
        return MIN(self.urlArray.count, self.titleArray.count);
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setViewControllerInputCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setViewControllerCell"];
        }
        [self inputCell:cell];
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setViewControllerListCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"setViewControllerCell"];
        }
        cell.textLabel.text = self.titleArray[indexPath.row];
        cell.detailTextLabel.text = self.urlArray[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (self.setBookSchemeUrlBlock) {
            self.setBookSchemeUrlBlock(self.urlArray[indexPath.row]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self.titleArray removeObjectAtIndex:indexPath.row];
            [self.urlArray removeObjectAtIndex:indexPath.row];
            [share(DRBookSchemeUrl) removeBookShcemeUrlModelAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - create cell

- (void)inputCell:(UITableViewCell *)cell
{
    UITextField *inputField = [UITextField createWithfont:DR_FONT_L3 color:nil];
    if (share(DRBookSchemeUrl).defaultBookWeb == nil) {
        inputField.text = @"http://www.";
    }else {
        inputField.placeholder = share(DRBookSchemeUrl).defaultBookWeb.baseUrl;
    }
    
    [cell.contentView addSubview:inputField];
    [inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(5.f, DR_UI_MARGIN, 5.f, 5+75+DR_UI_MARGIN));
    }];
    self.inputField = inputField;
    
    UIButton *btn = [UIButton createButton:DRButtonTypeDefault];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(inputOkClick) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(inputField);
        make.right.equalTo(cell.contentView).offset(-DR_UI_MARGIN);
        make.width.equalTo(@75.f);
    }];
}

- (void)inputOkClick
{
    if (self.setBookSchemeUrlBlock && self.inputField.text.length) {
        self.setBookSchemeUrlBlock(self.inputField.text);
        BookWebInfoModel *model = [BookWebInfoModel new];
        model.baseUrl = self.inputField.text;
        [share(DRBookSchemeUrl) addToBookWebList:model];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.view removeGestureRecognizer:self.tap];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view addGestureRecognizer:self.tap];
}

@end
