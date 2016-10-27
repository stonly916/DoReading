//
//  DRBookSchemeUrl.m
//  DoReading
//
//  Created by Wang Huiguang on 16/5/26.
//  Copyright © 2016年 ForHappy. All rights reserved.
//

#import "DRBookSchemeUrl.h"
#import "DRBookSchemeUrlModel.h"

@interface DRBookSchemeUrl()

@property (nonatomic, copy) NSString *bookShcemePath;
@property (nonatomic, strong) DRBookSchemeUrlModel *globalModel;

@end

@implementation DRBookSchemeUrl{
    OSSpinLock _storeLock;
}

IMP_SINGLETON(DRBookSchemeUrl)

- (NSString *)globalInfoDirectory
{// 文件存储目录 Document
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = paths.firstObject;
    return document;
}

- (void)initBaseInfo
{
    _storeLock = OS_SPINLOCK_INIT;
    
    self.bookShcemePath = [self.globalInfoDirectory stringByAppendingPathComponent:@"bookSchemeUrl"];
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:self.bookShcemePath];
    
    if (infoDict.count > 0) {
        NSError *error = nil;
        self.globalModel = [MTLJSONAdapter modelOfClass:DRBookSchemeUrlModel.class fromJSONDictionary:infoDict error:&error];
        if (error) {
            NSAssert(NO, @"%@",error);
        }
    }else {
        self.globalModel = [DRBookSchemeUrlModel new];
        self.globalModel.bookWebList = [NSMutableArray array];
    }
}

- (NSMutableArray *)bookWebList
{
    return self.globalModel.bookWebList;
}

- (void)setBookWebList:(NSMutableArray *)bookWebList
{
    self.globalModel.bookWebList = bookWebList;
    [self storeGeneralInfo];
}

- (BookWebInfoModel *)defaultBookWeb
{
    return self.globalModel.defaultBookWeb;
}

-(void)setDefaultBookWeb:(BookWebInfoModel *)defaultBookWeb
{
    self.globalModel.defaultBookWeb = defaultBookWeb;
    [self storeGeneralInfo];
}

- (void)storeGeneralInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.globalModel) {
            NSError *error = nil;
            NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:self.globalModel error:&error];
            if (!error) {
                OSSpinLockLock(&_storeLock);
                [dict writeToURL:[NSURL fileURLWithPath:self.bookShcemePath] atomically:YES];
                OSSpinLockUnlock(&_storeLock);
            }
        }
    });
}

@end
