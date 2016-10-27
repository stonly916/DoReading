//
//  DRBookSet.h
//  DoReading
//
//  Created by Wang Huiguang on 15/12/9.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DRReadDirection) {
    DRReadCurrent = 0,
    DRReadLast,
    DRReadNext
};

@interface DRBookSet : NSObject

@property (nonatomic, assign) NSInteger position;
@property (nonatomic, assign) NSUInteger currentWords;
@property (nonatomic, assign) NSRange currentRange;

@property (nonatomic, assign) CGFloat paragraphSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;

- (instancetype)initWithString:(NSString *)bookContent inSize:(CGSize)size;
- (void)setAttributesForBooks:(NSDictionary *)attributes;
//- (NSRange)rangeWithPosition:(NSInteger)position;
- (NSAttributedString *)stringWithPosition:(NSInteger)position direction:(DRReadDirection)direction;

- (NSAttributedString *)substringWithRange:(NSRange)range;

- (NSAttributedString *)lastString;
- (NSAttributedString *)nextString;
- (CGFloat)rate;
- (NSAttributedString *)showAttributedString;
@end
