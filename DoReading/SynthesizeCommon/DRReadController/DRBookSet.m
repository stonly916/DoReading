//
//  DRBookSet.m
//  DoReading
//
//  Created by Wang Huiguang on 15/12/9.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import "DRBookSet.h"
#import <CoreText/CoreText.h>

#define DEFAULT_SHOW_WORDS 1000

#define ENOUGH_HEIGHT 1500.f

@interface DRBookSet()

@property (nonatomic, copy) NSString *bookContent;

@property (nonatomic, strong) NSAttributedString *bookAttributedContent;

@property (nonatomic, strong) NSMutableDictionary *attributes;

@property (nonatomic, assign) CGSize bookSize;

//@property (nonatomic, strong) NSArray *rangeSets;

@end

@implementation DRBookSet

- (instancetype)initWithString:(NSString *)bookContent inSize:(CGSize)size
{
    if (self = [super init]) {
        _bookContent = bookContent;
        _bookSize = size;
        _position = 0;
        _currentRange = NSMakeRange(0, 0);
        _lineSpacing = 0.001;
        _paragraphSpacing = 0.001;
        [self setAttributesForBooks:self.defaultAttributes];
    }
    return self;
}

- (NSMutableDictionary *)defaultAttributes
{
    if (_attributes == nil) {
        NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
        UIFont * font = [UIFont systemFontOfSize:16.f];
        [attributes setValue:font forKey:NSFontAttributeName];
        [attributes setValue:@(0.0) forKey:NSLigatureAttributeName];
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = _lineSpacing;
        paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
        paragraphStyle.paragraphSpacing = _paragraphSpacing;
        paragraphStyle.headIndent = 0.0;
        paragraphStyle.tailIndent = 0.0;
        paragraphStyle.firstLineHeadIndent = 0.0;
        paragraphStyle.lineHeightMultiple = 1.0;
        paragraphStyle.maximumLineHeight = 0;
        paragraphStyle.minimumLineHeight = 0;
        paragraphStyle.paragraphSpacing = 0.0;
        paragraphStyle.paragraphSpacingBefore = 0.0;
        paragraphStyle.alignment = NSTextAlignmentNatural;
        [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
        _attributes = attributes;
    }
    return _attributes;
}

- (void)setAttributesForBooks:(NSMutableDictionary *)attributes
{
    UIFont *font = attributes[NSFontAttributeName];
    CGFloat change = 0.f;
    if (font) {
        change = 2 * font.pointSize;
    }
    
    self.bookSize = CGSizeMake(self.bookSize.width, self.bookSize.height - change);
    self.bookAttributedContent = [[NSAttributedString alloc] initWithString:self.bookContent attributes:attributes];
}

- (NSAttributedString *)stringWithPosition:(NSInteger)position direction:(DRReadDirection)direction
{
    if (position < 0) {
        return nil;
    }
    
    NSDate * date = [NSDate date];
    
    if (direction == DRReadNext) {
        
        NSInteger num = DEFAULT_SHOW_WORDS;
        
        if (position >= self.bookAttributedContent.length) {
            return nil;
        }
        
        if (position + num > self.bookAttributedContent.length) {
            num = self.bookAttributedContent.length - position;
        }
        
        NSAttributedString *childString = [self neededAttributeStringPosition:position length:num size:_bookSize];
        NSInteger length = [self nextVisibleLengthWithString:childString inSize:_bookSize];
        
        self.position = position;
        self.currentWords = length;
        self.currentRange = NSMakeRange(position, length);
    }else if (direction == DRReadLast) {
        position -= DEFAULT_SHOW_WORDS;
        if (position < 0) {
            position = 0;
        }
        NSInteger num = self.position - position;

        NSAttributedString *childString = [self neededAttributeStringPosition:position length:num size:_bookSize];
        NSInteger length = [self lastVisibleLengthWithString:childString inSize:_bookSize];
        
        //从开始到当前不足以显示满屏幕时，直接从0顺读
        if (num <= length) {
            self.position = 0;
            self.currentWords = 0;
            return self.nextString;
        }else {
            self.position -= length;
            self.currentWords = length;
            self.currentRange = NSMakeRange(self.position, length);
        }
    }
    NSTimeInterval millionSecond = [[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"耗时 %@", [NSString stringWithFormat:@"%lf", millionSecond]);
    NSAttributedString *showString = [self substringWithRange:self.currentRange];
    return showString;
}


- (NSAttributedString *)neededAttributeStringPosition:(NSInteger)position  length:(NSInteger)words size:(CGSize)size
{
    if (position < 0) {
        position = 0;
    }
    
    if (words <= 0) {
        return nil;
    }
    
    if (position + words >= self.bookAttributedContent.length) {
        words = self.bookAttributedContent.length - position;
    }
    
    CGFloat height = 0.0;
    NSAttributedString *childString;
    
    childString = [self.bookAttributedContent attributedSubstringFromRange:NSMakeRange(position, words)];
    
    CTFramesetterRef childFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) childString);
    // Initialize a rectangular path.
    CGRect bounds = CGRectMake(0.0, 0.0, size.width, DEFAULT_SHOW_WORDS);
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRect:bounds];
    
    CTFrameRef frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.CGPath, NULL);
    CFRelease(childFramesetter);
    
    CFArrayRef linesArray = CTFrameGetLines(frame);
    CFIndex count = CFArrayGetCount(linesArray);
    CGPoint origins[count];
    
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    height = DEFAULT_SHOW_WORDS - origins[count].y;
    
    CFRelease(frame);
    
    if (height < size.height && (position + words <= self.bookAttributedContent.length)){
        return [self neededAttributeStringPosition:position length:words + 100 size:size];
    }else {
        return childString;
    }
}

- (NSInteger)nextVisibleLengthWithString:(NSAttributedString *)attString inSize:(CGSize)size
{
    if (attString.length > 0) {
        
        CTFramesetterRef childFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attString);
        // Initialize a rectangular path.
        CGRect bounds = CGRectMake(0.0, 0.0, size.width, size.height);
        UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRect:bounds];
        
        CTFrameRef frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.CGPath, NULL);
        
        CFRelease(childFramesetter);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        CFRelease(frame);
        
        return range.length;
    }
    return 0;
}

- (NSInteger)lastVisibleLengthWithString:(NSAttributedString *)attString inSize:(CGSize)size
{
    if (attString.length > 0) {
        
        NSInteger length = 0;
        CGFloat lowPoint = 0.f;
        
        CTFramesetterRef childFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attString);
        // Initialize a rectangular path.
        CGRect bounds = CGRectMake(0.0, 0.0, size.width, ENOUGH_HEIGHT);
        UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRect:bounds];
        
        CTFrameRef frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.CGPath, NULL);
        
        CFRelease(childFramesetter);
        
        
        CFArrayRef lineArray = CTFrameGetLines(frame);
        CFIndex count = CFArrayGetCount(lineArray);
        
        //计算最后一行
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lineArray, count-1);
        
        CFRange lineRange = CTLineGetStringRange(line);
        length += lineRange.length;
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        CGPoint origins[count];
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
        lowPoint = origins[count -1].y + descent;
        
        for (CFIndex i = count-2; i >= 0; i--)
        {
            //计算高度
            CGPoint origin = origins[i];
            CGFloat currentPoint = origin.y + ascent;
            
            if (currentPoint - lowPoint >= size.height) {
                break;
            }else {
                CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lineArray, i);
                CFRange lineRange = CTLineGetStringRange(line);
                
                length += lineRange.length;
            }
        }
        
        CFRelease(frame);
    
        return length;
    }
    return 0;
}

- (NSAttributedString *)substringWithRange:(NSRange)range
{
    return [self.bookAttributedContent attributedSubstringFromRange:range];
}

- (NSAttributedString *)lastString
{
    return [self stringWithPosition:self.position direction:DRReadLast];
}

- (NSAttributedString *)nextString
{
    return [self stringWithPosition:self.position + self.currentWords direction:DRReadNext];
}

- (CGFloat)rate
{
    CGFloat rate;
    if (self.bookAttributedContent.length > 0) {
        rate = (self.position + self.currentWords) * 1.0 / self.bookAttributedContent.length;
        return rate * 100.0;
    }
    return 0.0f;
}

- (NSAttributedString *)showAttributedString
{
    return [self.bookAttributedContent attributedSubstringFromRange:self.currentRange];
}

@end
