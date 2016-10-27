//
//  DRBookSchemeUrlModel.m
//  DoReading
//
//  Created by Wang Huiguang on 16/5/26.
//  Copyright © 2016年 ForHappy. All rights reserved.
//

#import "DRBookSchemeUrlModel.h"

@implementation DRBookSchemeUrlModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"bookWebList":@"bookWebList",
             @"defaultBookWeb":@"defaultBookWeb"
             };
}

+ (NSValueTransformer *)bookWebListJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *arr, BOOL *success, NSError *__autoreleasing *error) {
        NSArray *array = [MTLJSONAdapter modelsOfClass:BookWebInfoModel.class fromJSONArray:arr error:error];
        return [array mutableCopy];
    } reverseBlock:^id(NSMutableArray *arr, BOOL *success, NSError *__autoreleasing *error) {
        NSArray *array = [MTLJSONAdapter JSONArrayFromModels:arr error:error];
        return array;
    }];
}

+ (NSValueTransformer *)defaultBookWebTransformer
{
    return [NSValueTransformer mtl_validatingTransformerForClass:BookWebInfoModel.class];
}

@end

@implementation BookWebInfoModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"webName":@"webName",
             @"baseUrl":@"baseUrl",
             };
}

@end