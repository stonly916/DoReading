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

@implementation DRBookSchemeUrl

IMP_SINGLETON(DRBookSchemeUrl)

- (NSString *)globalInfoDirectory
{// 文件存储目录 Document
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = paths.firstObject;
    return document;
}

- (void)initBaseInfo
{
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

- (BookWebInfoModel *)defaultBookWeb
{
    return self.globalModel.defaultBookWeb;
}

- (NSMutableArray *)bookWebList
{
    return self.globalModel.bookWebList;
}

- (void)addToBookWebList:(BookWebInfoModel *)model
{
    self.globalModel.defaultBookWeb = model;
    [self.globalModel.bookWebList addObject:model];
    [self storeGeneralInfo];
}

- (void)removeBookShcemeUrlModelAtIndex:(NSUInteger)index
{
    if (self.globalModel.bookWebList.count > index) {
        [self.globalModel.bookWebList removeObjectAtIndex:index];
        [self storeGeneralInfo];
    }
}

- (void)removeBookShcemeUrlModel:(BookWebInfoModel *)model
{
    if ([self.globalModel.bookWebList containsObject:model]) {
        [self.globalModel.bookWebList removeObject:model];
        [self storeGeneralInfo];
    }
}

- (void)storeGeneralInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.globalModel) {
            NSError *error = nil;
            NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:self.globalModel error:&error];
            if (!error) {
                ST_SEMAPHORE_LOCK(@"bookSchemeLock",[dict writeToURL:[NSURL fileURLWithPath:self.bookShcemePath] atomically:YES]);
                ;
            }
        }
    });
}

@end
