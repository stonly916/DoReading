//
//  BooksManager.h
//  DoReading
//
//  Created by Wang Huiguang on 15/11/25.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookModel.h"

typedef NS_ENUM(NSUInteger, BooksManagerWay) {
    BooksManagerNone,
    BooksManagerLocation,
    BooksManagerDesk
};

typedef void (^Completed)(BookModel *model);

@interface BooksManager : NSObject

+(void)instanceSignalManager;

+ (NSArray *)getAllBooksName;

+ (void)bookModelForLocation:(NSString *)name completed:(Completed)completed;

+ (void)bookDateForLocatin:(NSString *)name completed:(void(^)(NSData *data,NSStringEncoding encode, NSError *error))completed;

//更新后获取数据
+ (void)booksInLocationUpdateWithArray:(void(^)(NSArray *array))complete;
+ (void)booksInLocationUpdateExpectDeskWithArray:(void(^)(NSArray *array))complete;
@end

@interface BooksManager(BookDestTop)

+ (NSArray *)getAllDeskBooksName;

+ (void)bookModelInDeskLog:(NSString *)name completed:(Completed)completed;

+ (void)bookModelsInDeskLog:(void(^)(NSArray *modelArray))completed;

+ (void)addBookModelstoDeskLog:(NSArray *)models complete:(void(^)(NSArray *modelArray))completed;

+ (void)storeDeskLog;

@end