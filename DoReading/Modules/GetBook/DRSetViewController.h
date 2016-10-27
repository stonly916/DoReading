//
//  DRSetViewController.h
//  DoReading
//
//  Created by Wang Huiguang on 16/5/27.
//  Copyright © 2016年 ForHappy. All rights reserved.
//

#import "DRBaseTableViewController.h"

@interface DRSetViewController : DRBaseTableViewController

@property (nonatomic, copy) void(^setBookSchemeUrlBlock)(NSString *urlStr);

@property (nonatomic, copy) NSString *bookSchemeUrl;

@end
