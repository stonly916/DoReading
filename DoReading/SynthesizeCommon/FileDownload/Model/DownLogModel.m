//
//  DownLogModel.m
//  DoReading
//
//  Created by Wang Huiguang on 15/10/30.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import "DownLogModel.h"

@implementation DownLogModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"url":@"url",
             @"fileCachePath":@"fileCachePath",
             @"fileDownloadPath":@"fileDownloadPath",
             @"time":@"time",
             @"progress":@"progress",
             @"state":@"state"
             };
}

+ (NSValueTransformer *)urlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)stateJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @(-1): @(DownOperationPausedState),
                                                                           @(0): @(DownOperationUnkown),
                                                                           @(1): @(DownOperationReadyState),
                                                                           @(2):@(DownOperationExecutingState),
                                                                           @(3):@(DownOperationFinishedState)
                                                                           } defaultValue:@(DownOperationUnkown) reverseDefaultValue:@(DownOperationUnkown)];
}

@end
