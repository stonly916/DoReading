//
//  DRHomeViewController.m
//  DoReading
//
//  Created by Wang Huiguang on 15/10/26.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import "DRHomeViewController.h"
#import "DRAddLocationViewController.h"
#import "DRReadBookViewController.h"

#import "DRCollectionLayout.h"
#import "DRBookDeskTopViewCell.h"

#define DRCollectionCellString @"homeCollectionCell"

@interface DRHomeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *deskBooksArray;

@end

@implementation DRHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self deskBooks];
    //导航栏添加新书
    [self addRightButton];
    
    [self addCollectionView];
}

- (void)deskBooks
{
    self.deskBooksArray = [NSMutableArray array];
    
    @weakify(self);
    [BooksManager bookModelsInDeskLog:^(NSArray *modelArray) {
        @strongify(self);
        self.deskBooksArray = modelArray;
        [self.collectionView reloadData];
    }];
}

- (void)addCollectionView
{
    DRCollectionLayout *layout = [[DRCollectionLayout alloc] init];
    CGFloat width = (SCREEN_WIDTH - 50 - 30)/2;
    if (IS_IPHONE_6_OR_BIGGER) {
        width = (SCREEN_WIDTH - 50 - 60)/3;
    }
    layout.itemSize = CGSizeMake(width, width * 7.0/6);
    layout.minimumInteritemSpacing = 30.f;
    layout.minimumLineSpacing = 25.f;
    layout.sectionInset = UIEdgeInsetsMake(25.f, 25.f, 0, 25.f);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[DRBookDeskTopViewCell class] forCellWithReuseIdentifier:DRCollectionCellString];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self.view addSubview:_collectionView];
}

- (void)addRightButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarItemClick:)];
}

- (void)rightBarItemClick:(UIBarButtonItem *)item
{
    DRAddLocationViewController *locationVc = [[DRAddLocationViewController alloc] init];
    @weakify(self);
    locationVc.getBookModel = ^(NSArray *bookModels){
        [BooksManager addBookModelstoDeskLog:bookModels complete:^(NSArray *modelArray) {
            @strongify(self);
            self.deskBooksArray = modelArray;
            [self.collectionView reloadData];
        }];
    };
    
    [self.navigationController pushViewController:locationVc animated:YES];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.deskBooksArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookModel *model = self.deskBooksArray[indexPath.item];
    DRBookDeskTopViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DRCollectionCellString forIndexPath:indexPath];
    cell.backgroundColor = DR_COLOR_CODE(@"#c27520");
    [cell setName:model.bookName size:[NSString stringWithSize:model.bookSize]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookModel *model = self.deskBooksArray[indexPath.item];
    DRReadBookViewController *readVc = [[DRReadBookViewController alloc] init];
    readVc.hidesBottomBarWhenPushed = YES;
    [readVc loadReadViewControllerWith:model];
    [self.navigationController pushViewController:readVc animated:YES];
}

@end
