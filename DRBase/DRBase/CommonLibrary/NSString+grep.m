//
//  NSString+grep.m
//  pyd
//
//  Created by Wang Huiguang on 15/10/27.
//  Copyright © 2015年 iOS. All rights reserved.
//

#import "NSString+grep.h"

typedef unsigned long long TFileSize;

@implementation NSString(grep)

+ (NSString *)stringWithSize:(long long)size
{
    NSString *totalSize = @"0.00 B";
    TFileSize b_Size = 0;
    TFileSize kb_Size = 0;
    TFileSize m_Size = 0;
    TFileSize g_Size = 0;
    
    b_Size = size;
    if (b_Size >= 1024) {
        kb_Size = b_Size / 1024;
        b_Size = b_Size % 1024;
        if (kb_Size >= 1024) {
            m_Size = kb_Size / 1024;
            kb_Size = kb_Size % 1024;
            if (m_Size >= 1024) {
                g_Size = m_Size / 1024;
                m_Size = m_Size % 1024;
                if (g_Size >= 1024) {
                    totalSize = @"Max";
                }else {
                    totalSize = [NSString stringWithFormat:@"%.3f G",(g_Size + m_Size*1.0/1024)];
                }
                
            }else {
                totalSize = [NSString stringWithFormat:@"%.3f M",(m_Size + kb_Size*1.0/1024)];
            }
            
        }else {
            totalSize = [NSString stringWithFormat:@"%.3f KB",(kb_Size + b_Size*1.0/1024)];
        }
    }else if(b_Size > 0){
        totalSize = [NSString stringWithFormat:@"%lld B",kb_Size];
    }
    
    return totalSize;
}

- (BOOL)isStringForGrep:(NSString *)grep
{
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", grep];
    return [emailTest evaluateWithObject:self];
}

- (NSString *)getTotalName
{
    return [self componentsSeparatedByString:@"/"].lastObject;
}

- (NSString *)getName
{
    NSRange range = [self rangeOfString:@"." options:NSBackwardsSearch];
    if (range.length > 0 && range.location > 0){
        return [self substringToIndex:range.location];
    } else {
        return self;
    }
}

- (NSString *)getExtendName
{
    return [self componentsSeparatedByString:@"."].lastObject;
}

@end
