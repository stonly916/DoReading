//
//  DRBookSchemeUrl.h
//  DoReading
//
//  Created by Wang Huiguang on 16/5/26.
//  Copyright © 2016年 ForHappy. All rights reserved.
//

#import "DRBookSchemeUrlModel.h"

@interface DRBookSchemeUrl : NSObject

- (BookWebInfoModel *)defaultBookWeb;
- (NSMutableArray *)bookWebList;

+ (DRBookSchemeUrl *)sharedInstance;

- (void)initBaseInfo;

- (void)addToBookWebList:(BookWebInfoModel *)model;
- (void)removeBookShcemeUrlModel:(BookWebInfoModel *)model;
- (void)removeBookShcemeUrlModelAtIndex:(NSUInteger)index;

@end
