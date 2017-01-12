//
//  BooksManager.m
//  DoReading
//
//  Created by Wang Huiguang on 15/11/25.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import "BooksManager.h"

@interface BooksManager(){
    OSSpinLock _storeLock;
}

@property (nonatomic, copy, readonly) NSString *bookStoreDirectory;

@property (nonatomic, copy) NSString *booksDeskLogPath;
@property (nonatomic, copy) NSString *booksLogPath;

//桌面
@property (nonatomic, strong) NSMutableDictionary *booksDeskDict;
//真实
@property (nonatomic, strong) NSMutableDictionary *booksLogDict;

@end

@implementation BooksManager

- (instancetype)instance
{
    _storeLock = OS_SPINLOCK_INIT;
    
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    _bookStoreDirectory = [arr.firstObject stringByAppendingString:@"/FileStore/"];
    
    _booksDeskLogPath = [arr.firstObject stringByAppendingString:@"/booksDeskLog"];
    _booksLogPath = [arr.firstObject stringByAppendingString:@"/booksLog"];
    
    _booksDeskDict = [self updateDeskLog];
    _booksLogDict = [self updateLocationLog];
    
    return self;
}

+ (instancetype)manager
{
    static BooksManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[[BooksManager alloc] init] instance];
        
    });
    return manager;
}

+(void)instanceSignalManager
{
    [BooksManager manager];
}

#pragma mark - 类方法，获得文件全名
+ (NSArray *)getAllBooksName
{
    BooksManager *manager = [BooksManager manager];
    return manager.booksLogDict.allKeys;
}

#pragma mark - 根据名称获得书籍model
+ (void)bookModelForLocation:(NSString *)name completed:(Completed)completed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BooksManager *manager = [BooksManager manager];
        BookModel *model = manager.booksLogDict[name];
        completed(model);
    });
}

+ (void)bookModelForDesk:(NSString *)name completed:(Completed)completed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BooksManager *manager = [BooksManager manager];
        BookModel *model = manager.booksDeskDict[name];
        completed(model);
        [manager store:BooksManagerDesk];
    });
}

#pragma mark - 解码

+ (NSStringEncoding)encodingForData:(NSData *)data
{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    if (data.length >= 2) {
        NSString *str = [[NSString alloc] initWithBytes:[data bytes] length:2 encoding:gbkEncoding];
        if (str.length > 0) {
            return gbkEncoding;
        }
    }
    return 0;
}
#pragma mark - 输出文件数据
+ (void)bookDateForLocatin:(NSString *)name completed:(void(^)(NSData *data,NSStringEncoding encode, NSError *error))completed
{
    BooksManager *manager = [BooksManager manager];
    NSString *path = [manager.bookStoreDirectory stringByAppendingPathComponent:name];
    //如果文件被删
    if (![CFileHandle containFileAtPath:path]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completed(nil,0,nil);
            return;
        });
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSStringEncoding encode;
    NSError *error = nil;
    [NSString stringWithContentsOfFile:path usedEncoding:&encode error:&error];
    if (error) {
        encode = [BooksManager encodingForData:data];
        if (encode == 0) {
            error = [[NSError alloc] initWithDomain:@"the file can't be encoded" code:566 userInfo:@{@"path":path}];
        }else {
           error = nil;
        }
    }

    completed(data,encode,error);
}

//读取Desklog
- (NSMutableDictionary *)getDeskLogInfo
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:_booksDeskLogPath];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
    }
    return dict;
}

//获取桌面书籍
- (NSMutableDictionary *)updateDeskLog
{
    NSMutableDictionary *deskDict = [self getDeskLogInfo];
    //桌面书籍Log
    for (NSString *key in deskDict.allKeys) {
        NSDictionary *dict = deskDict[key];
        
        NSError *error = nil;
        BookModel *model = [MTLJSONAdapter modelOfClass:[BookModel class] fromJSONDictionary:dict error:&error];
        if (error == nil) {
            [deskDict setValue:model forKey:key];
        }else {
            NSLog(@"BooksManager-%@",error);
            [deskDict removeObjectForKey:key];
        }
        
    }
    
    return deskDict;
}

#pragma mark - 更新本地书籍
+ (void)booksInLocationUpdateWithArray:(void(^)(NSArray *array))complete
{
    BooksManager *manager = [BooksManager manager];
    [manager updateLocationBooks:^(NSDictionary *dictionary) {
        if (dictionary.count > 0) {
            complete(dictionary.allValues);
        } else {
            complete(@[]);
        }
    }];
}

+ (void)booksInLocationUpdateExpectDeskWithArray:(void(^)(NSArray *array))complete
{
    BooksManager *manager = [BooksManager manager];
    [manager updateLocationBooks:^(NSDictionary *dictionary) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *key in dictionary.allKeys) {
            if (nil == [manager.booksDeskDict objectForKey:key]) {
                [arr addObject:dictionary[key]];
            }
        }
        complete(arr);
    }];
}

#pragma mark - 获得所有书籍文件名
-(NSArray *)allLocatoinBooksName
{
    NSArray *arr = [CFileHandle getContentsbyDir:self.bookStoreDirectory];
    if (arr == nil) {
        return [NSArray array];
    }
    return arr;
}
//根据本地文件名 获取bookModel
- (BookModel *)modelByName:(NSString *)name
{
    NSString *path = [_bookStoreDirectory stringByAppendingPathComponent:name];
    
    BookModel *model = [[BookModel alloc] init];
    model.bookName = name;
    model.state = DRBookPositionNone;
    model.bookSize = [CFileHandle getFileSize:path];
    return model;
}

//根据本地文件路径 获取bookModel
- (BookModel *)modelByPath:(NSString *)path
{
    BookModel *model = [[BookModel alloc] init];
    model.bookName = [path getTotalName];
    model.state = DRBookPositionNone;
    model.bookSize = [CFileHandle getFileSize:path];
    return model;
}

//更新本地书籍
- (NSMutableDictionary *)updateLocationLog
{
    NSMutableDictionary *LocationDict = [NSMutableDictionary dictionary];
    //根据本地文件获取数据
    for (NSString *name in [self allLocatoinBooksName]) {
        BookModel *model = [self modelByName:name];
        [LocationDict setValue:model forKey:name];
    }
    
    return LocationDict;
}

//更新本地书籍记录
- (void)updateLocationBooks:(void(^)(NSDictionary *dictionary))complete
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.booksLogDict = [self updateLocationLog];
        [self store:BooksManagerLocation];
        complete(self.booksLogDict);
    });
}

- (void)store:(BooksManagerWay)way
{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        NSDictionary *logDict = @{};
        NSString *path = @"";
        if (way == BooksManagerDesk) {
            logDict = self.booksDeskDict;
            path = self.booksDeskLogPath;
        }else if(way == BooksManagerLocation){
            logDict = self.booksLogDict;
            path = self.booksLogPath;
        }else {
            return;
        }
        
        if (logDict.count > 0) {
            if (path.length > 0) {
                NSMutableDictionary *writeLog = [NSMutableDictionary dictionary];
                for (NSString *key in logDict.allKeys) {
                    NSError *error = nil;
                    DownLogModel *model = logDict[key];
                    NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:model error:&error];
                    if (!error && dict) {
                        [writeLog setObject:dict forKey:key];
                    }else {
                        NSLog(@"BooksManager-%@",error);
                    }
                }
                
                if (writeLog.count > 0) {
                    OSSpinLockLock(&_storeLock);
                    [writeLog writeToFile:path atomically:YES];
                    OSSpinLockUnlock(&_storeLock);
                }
            }
        }
    });
}


@end

@implementation BooksManager(BookDestTop)
+ (NSArray *)getAllDeskBooksName
{
    BooksManager *manager = [BooksManager manager];
    return manager.booksDeskDict.allKeys;
}

+ (void)bookModelInDeskLog:(NSString *)name completed:(Completed)completed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BooksManager *manager = [BooksManager manager];
        BookModel *model = manager.booksDeskDict[name];
        completed(model);
        [manager store:BooksManagerDesk];
    });
}

#pragma mark - 查看书桌记录
+ (void)bookModelsInDeskLog:(void(^)(NSArray *modelArray))completed
{
    BooksManager *manager = [BooksManager manager];

    if(manager.booksDeskDict.count > 0) {
        completed(manager.booksDeskDict.allValues);
    } else {
        completed(@[]);
    }
}

+ (void)addBookModelstoDeskLog:(NSArray *)models complete:(void(^)(NSArray *modelArray))completed
{
    BooksManager *manager = [BooksManager manager];
    for (id book in models) {
        if ([book isKindOfClass:[BookModel class]]) {
            BookModel *model = book;
            [manager.booksDeskDict setObject:model forKey:model.bookName];
        }
    }
    
    if(manager.booksDeskDict.count > 0) {
        completed(manager.booksDeskDict.allValues);
    } else {
        completed(@[]);
    }
    [self storeDeskLog];
}

+ (void)storeDeskLog
{
    [[BooksManager manager] store:BooksManagerDesk];
}
@end
