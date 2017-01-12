//
//  DRBookSet.m
//  DoReading
//
//  Created by Wang Huiguang on 15/12/9.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#import "DRBookSet.h"
#import <CoreText/CoreText.h>

/**
 *                    .::::.
 *                  .::::::::.
 *                 :::::::::::
 *             ..:::::::::::'
 *           '::::::::::::'
 *             .::::::::::
 *        '::::::::::::::..
 *             ..::::::::::::.
 *           ``::::::::::::::::
 *            ::::``:::::::::'        .:::.
 *           ::::'   ':::::'       .::::::::.
 *         .::::'      ::::     .:::::::'::::.
 *        .:::'       :::::  .:::::::::' ':::::.
 *       .::'        :::::.:::::::::'      ':::::.
 *      .::'         ::::::::::::::'         ``::::.
 *  ...:::           ::::::::::::'              ``::.
 * ```` ':.          ':::::::::'                  ::::..
 *                    '.:::::'                    ':'````..
 * 当前为任意位置读取页面 ---->>>---- 下一步，根据章节读取字符串，分解每一页range,固定页面显示
 */


#define NSRange_NF(range) NSMakeRange(range.location,range.length)

#define DEFAULT_SHOW_WORDS 888

#define ENOUGH_HEIGHT 1500.f

@interface NSAttributedString(outReturn)
- (NSAttributedString *)outSuffixReturnSymbol;
@end
@implementation NSAttributedString(outReturn)
- (NSAttributedString *)outSuffixReturnSymbol
{
    NSAttributedString *att = self;
    if (att.length == 1) {
        return att;
    }else if ([att.string hasSuffix:@"\n"]) {
        att = [att attributedSubstringFromRange:NSMakeRange(0, att.length-1)];
    }else if ([att.string hasPrefix:@"\n"]) {
        att = [att attributedSubstringFromRange:NSMakeRange(1, att.length - 1)];
    }else {
        return att;
    }
    return [att outSuffixReturnSymbol];
}

@end

@interface DRBookSet()

@property (nonatomic, copy) NSString *bookContent;

@property (nonatomic, assign) long long wordsNumber;

@property (nonatomic, strong) NSAttributedString *bookAttributedContent;

@property (nonatomic, assign) CGSize bookSize;

@end

@implementation DRBookSet

- (instancetype)initWithString:(NSString *)bookContent inSize:(CGSize)size
{
    if (self = [super init]) {
        _bookContent = bookContent;
        _bookSize = size;
        
        _position = 0;
        _currentWords = 0;
        _currentRange = NSMakeRange(0, 0);
        
        self.bookContent = [self analyseString:bookContent];
        _wordsNumber = self.bookContent.length;
        self.bookAttributedContent = [[NSAttributedString alloc] initWithString:self.bookContent attributes:self.defaultAttributes];
    }
    return self;
}

- (NSMutableDictionary *)defaultAttributes
{
    _fontSize = 16.f;
    _firstLineInset = 0.;
    _lineSpacing = 2.25f;
    _paragraphSpacing = 5.f;
    if (_attributes == nil) {
        NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
        UIFont * font = [UIFont fontWithName:@"KaiTi_GB2312" size:_fontSize];
        [attributes setValue:font forKey:NSFontAttributeName];
        attributes[NSForegroundColorAttributeName] = [UIColor blackColor];
        
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = _lineSpacing;
        paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;   // 折行方式
        paragraphStyle.paragraphSpacing = _paragraphSpacing;
        paragraphStyle.paragraphSpacingBefore = 0.f;  //段落之前的间距
        paragraphStyle.headIndent = 0.f;    // 非首行文本缩进
        paragraphStyle.tailIndent = 0.f;    // 文本缩进(右端)
        paragraphStyle.firstLineHeadIndent = _firstLineInset;
        paragraphStyle.maximumLineHeight = _fontSize;
        paragraphStyle.minimumLineHeight = _fontSize;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
        _attributes = attributes;
    }
    return _attributes;
}

-(void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [(UIFont *)self.attributes[NSFontAttributeName] fontWithSize:fontSize];
}

- (void)setAttributesForBooks:(NSMutableDictionary *)attributes
{
    _attributes = attributes;
    self.bookAttributedContent = [[NSAttributedString alloc] initWithString:self.bookContent attributes:attributes];
}

#pragma mark - 预处理字符串
- (NSString *)analyseString:(NSString *)string
{
    if ([string containsString:@"\r"]) {
        string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    }
    if ([string containsString:@"\n\n"]) {
        string = [string stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    }else {
        return string;
    }
    
    return [self analyseString:string];
}

#pragma mark -

- (NSAttributedString *)stringWithPosition:(NSInteger)position direction:(DRReadDirection)direction
{
    NSAttributedString *getAttributeStr;
    if (position < 0 || position >= _wordsNumber) {
        return getAttributeStr;
    }
    
    NSDate * date = [NSDate date];
    
    if (direction == DRReadNext) {
        
        NSInteger num = DEFAULT_SHOW_WORDS;
        if (position + DEFAULT_SHOW_WORDS > _wordsNumber) {
            num = _wordsNumber - position;
        }
        
        NSAttributedString *childString = [self.bookAttributedContent attributedSubstringFromRange:NSMakeRange(position, num)];
        NSRange range = [self nextVisibleStringRange:childString inSize:_bookSize];
        getAttributeStr = [childString attributedSubstringFromRange:range];
        
        self.position = position;
        self.currentWords = range.length;
        self.currentRange = NSMakeRange(self.position, self.currentWords);
    }else if (direction == DRReadLast) {
        if (position == 0) {
            return getAttributeStr;
        }
        
        position -= DEFAULT_SHOW_WORDS;
        if (position < 0) {
            position = 0;
            return [self stringWithPosition:position direction:DRReadNext];
        }
        
        NSAttributedString *childString = [self.bookAttributedContent attributedSubstringFromRange:NSMakeRange(position, DEFAULT_SHOW_WORDS)];
        NSRange range = [self lastVisibleLengthWithString:childString inSize:_bookSize];
        getAttributeStr = [childString attributedSubstringFromRange:range];
        
        self.position = position + DEFAULT_SHOW_WORDS - range.length;
        self.currentWords = range.length;
        self.currentRange = NSMakeRange(self.position, self.currentWords);
    }else {
        getAttributeStr = self.bookAttributedContent;
    }
    NSTimeInterval millionSecond = [[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"耗时 %@", [NSString stringWithFormat:@"%lf", millionSecond]);
    
    NSAttributedString *attri = [getAttributeStr outSuffixReturnSymbol];
    return attri;
}

- (NSAttributedString *)lastString
{
    return [self stringWithPosition:self.position direction:DRReadLast];
}

- (NSAttributedString *)nextString
{
   return [self stringWithPosition:(self.position + self.currentWords) direction:DRReadNext];
}

- (CGFloat)rate
{
    CGFloat rate;
    if (_wordsNumber > 0) {
        rate = (self.position + self.currentWords) * 1.0 / _wordsNumber;
        return rate * 100.0;
    }
    return 0.0f;
}

- (NSAttributedString *)rollToRate:(CGFloat)rate
{
    NSInteger position = (NSInteger)floorf(rate * _wordsNumber);
    return [self stringWithPosition:position direction:DRReadNext];
}

#pragma mark - 上下翻页计算

- (NSRange)lastVisibleLengthWithString:(NSAttributedString *)attString inSize:(CGSize)size
{
    if (attString.length > 0) {
        
        NSInteger length = 0;
        CGFloat rectHeight = 0.f;
        
        CTFramesetterRef childFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attString);
        // Initialize a rectangular path.
        CGRect bounds = CGRectMake(0.0, 0.0, size.width, CGFLOAT_MAX);
        UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRect:bounds];
        CTFrameRef frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.CGPath, NULL);
        CFRelease(childFramesetter);
        
        
        CFArrayRef lineArray = CTFrameGetLines(frame);
        CFIndex count = CFArrayGetCount(lineArray);
        
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        
        for (CFIndex i = count-1; i >= 0; i--) {
            CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lineArray, i);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CFRange lineRange = CTLineGetStringRange(line);
            
            NSAttributedString *str = [attString attributedSubstringFromRange:NSRange_NF(lineRange)];
            
            if (i != count -1) {
                //非最后一行，计算行间距和段间距要在判断之前
                rectHeight += _lineSpacing;
                if ([str.string hasSuffix:@"\n"]) {
                    //段间距
                    rectHeight += _paragraphSpacing;
                }
            }
            //行高
            rectHeight += ascent + descent;
            
            if (rectHeight < size.height) {
                length += lineRange.length;
            }else {
                break;
            }
        }
        
        CFRelease(frame);
        
        return NSMakeRange(attString.length - length, length);
    }
    return NSMakeRange(0, 0);
}

- (NSRange)nextVisibleStringRange:(NSAttributedString *)attString inSize:(CGSize)size
{
    if (attString.length > 0) {
        
        CTFramesetterRef childFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attString);
        CGRect bounds = CGRectMake(0.0, 0.0, size.width, CGFLOAT_MAX);
        UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRect:bounds];
        CTFrameRef frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.CGPath, NULL);

        
        CFRelease(childFramesetter);
        
        CFArrayRef lineArray = CTFrameGetLines(frame);
        CFIndex count = CFArrayGetCount(lineArray);
        
        NSInteger length = 0;
        CGFloat rectHeight = 0.f;
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        
        for (CFIndex i = 0; i < count; i++) {
            CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lineArray, i);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CFRange lineRange = CTLineGetStringRange(line);
            
            NSAttributedString *str = [attString attributedSubstringFromRange:NSRange_NF(lineRange)];
            
            //行高
            rectHeight += ascent + descent;
            
            if (rectHeight < size.height) {
                //第一行满足条件后，其后每一行计算加入之上的行间距和段间距
                length += lineRange.length;
                rectHeight += _lineSpacing;
                if ([str.string hasSuffix:@"\n"]) {
                    //段间距
                    rectHeight += _paragraphSpacing;
                }
            }else {
                break;
            }
        }

        CFRelease(frame);
        return NSMakeRange(0, length);
    }
    return NSMakeRange(0, 0);
}

@end
