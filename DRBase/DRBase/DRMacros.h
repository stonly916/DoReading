//
//  DRMacros.h
//  DoReading
//
//  Created by Wang Huiguang on 15/10/29.
//  Copyright © 2015年 ForHappy. All rights reserved.
//

#ifndef DRMacros_h
#define DRMacros_h

//单例
#undef IMP_SINGLETON
#define IMP_SINGLETON(_class)\
+(_class *)sharedInstance\
{\
static dispatch_once_t once;\
static _class *cs;\
dispatch_once(&once,^{\
cs = [[_class alloc] init];\
});\
return cs;\
}

#define share(class) [class sharedInstance]

//字符串判断
#define DR_NONNULL_STRING(string) (string.length ? string:@"")

//系统版本判断
#define IS_OS_6_OR_EARLIER         ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.99)
#define IS_OS_7_OR_EARLIER         ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.99)
#define IS_OS_7_OR_LATER           ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER           ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_OS_9_OR_LATER           ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

#define IS_IPHONE                  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5                (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 568.0) &&  ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))
#define IS_STANDARD_IPHONE_6       (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)
#define IS_ZOOMED_IPHONE_6         (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)
#define IS_STANDARD_IPHONE_6_PLUS  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_ZOOMED_IPHONE_6_PLUS    (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)


#define IS_IPHONE_5_OR_BIGGER       (IS_IPHONE_5 || IS_STANDARD_IPHONE_6 || IS_ZOOMED_IPHONE_6 || IS_STANDARD_IPHONE_6_PLUS || IS_ZOOMED_IPHONE_6_PLUS || (SCREEN_HEIGHT >= 568.0))
#define IS_IPHONE_6_OR_BIGGER   (IS_STANDARD_IPHONE_6 || IS_ZOOMED_IPHONE_6 || IS_STANDARD_IPHONE_6_PLUS || IS_ZOOMED_IPHONE_6_PLUS || (SCREEN_HEIGHT >= 568.0 && !IS_IPHONE_5))

//获取屏幕大小
#define  SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define  SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

//通用距离
//边缘距离
#define DR_UI_MARGIN 15.f

//字体
//L1字体，例如section的title大小，标题，按钮
#define DR_FONT_L1         [UIFont systemFontOfSize:(IS_IPHONE_6_OR_BIGGER?20.f:19.f)]
#define DR_FONT_L1_BOLD    [UIFont boldSystemFontOfSize:(IS_IPHONE_6_OR_BIGGER?20.f:19.f)]
//L2字体，例如cell的name大小，常规
#define DR_FONT_L2         [UIFont systemFontOfSize:16.f]
#define DR_FONT_L2_BOLD    [UIFont boldSystemFontOfSize:16.f]
//L3字体
#define DR_FONT_L3         [UIFont systemFontOfSize:15.f]
//L4字体
#define DR_FONT_L4         [UIFont systemFontOfSize:14.f]
//L5字体，最小，辅助
#define DR_FONT_L5         [UIFont systemFontOfSize:13.f]

//颜色
#import "UIColor+colorForCode.h"

#define DR_COLOR_CODE(code) [UIColor colorWithCode:code]

// 通用颜色
#define DR_COLOR_COMMON_BG             DR_COLOR_CODE(@"#f4f4f4")
#define DR_COLOR_SEPARATOR             DR_COLOR_CODE(@"#e1e1e1")
#define DR_COLOR_UNEDIT_INPUT_BG       DR_COLOR_CODE(@"#f6f6f6")
#define DR_COLOR_COMMON_WARM           DR_COLOR_CODE(@"#ff6600")
#define DR_COLOR_COMMON_COOL           DR_COLOR_CODE(@"#2577e3")

// 通用字体颜色
#define DR_COLOR_FONT_DARK             DR_COLOR_CODE(@"#333333")
#define DR_COLOR_FONT_MIDDLE           DR_COLOR_CODE(@"#666666")
#define DR_COLOR_FONT_LIGHT            DR_COLOR_CODE(@"#999999")
#define DR_COLOR_FONT_WARM             DR_COLOR_CODE(@"#ff6600")
#define DR_COLOR_FONT_COOL             DR_COLOR_CODE(@"#2577e3")
#define DR_COLOR_FONT_PLACEHOLDER      DR_COLOR_CODE(@"#cccccc")

#define  COM_COLOR_BLUE [UIColor colorWithRed:23/255.0 green:152/255.0 blue:185/255.0 alpha:1]
#define  COLOR_BOOKCOVER_WARM [UIColor colorWithRed:194/255.0 green:117/255.0 blue:32/255.0 alpha:1]

//书本颜色207	140	76
#define  COLOR_BOOK_ORANGE [UIColor colorWithRed:203/255.0 green:165/255.0 blue:120/255.0 alpha:1]

#endif /* DRMacros_h */
