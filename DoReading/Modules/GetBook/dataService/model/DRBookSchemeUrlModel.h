//
//  DRBookSchemeUrlModel.h
//  DoReading
//
//  Created by Wang Huiguang on 16/5/26.
//  Copyright © 2016年 ForHappy. All rights reserved.
//

#import <Mantle/Mantle.h>
@class BookWebInfoModel;

//全局变量
@interface DRBookSchemeUrlModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSMutableArray *bookWebList;

@property (nonatomic, strong) BookWebInfoModel *defaultBookWeb;

@end

@interface BookWebInfoModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *webName;

@property (nonatomic, copy) NSString *baseUrl;

@end


