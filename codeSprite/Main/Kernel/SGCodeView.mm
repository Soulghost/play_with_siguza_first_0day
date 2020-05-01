//
//  SGCodeView.m
//  codeSprite
//
//  Created by 11 on 12/18/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import "SGCodeView.h"
#import "SGCodeTextView.h"
#import "RegexKitLite.h"
#import "TextSegment.h"
#import "MBProgressHUD+MJ.h"
#import "SGIndexManager.h"
#import "NSMutableAttributedString+SGExtension.h"

// C++
#include <stack>
#include <string>
#include <sstream>
#include <algorithm>
using namespace std;

#define RegexSegment(param) [NSString stringWithFormat:@"\\b%@\\b",param]
#define CodeFont [UIFont systemFontOfSize:15]
#define CoverTag 1

@interface SGCodeView () <UITextViewDelegate>

@property (nonatomic, weak) SGCodeTextView *textView;
@property (nonatomic, assign) BOOL hasOffset;

@end

@implementation SGCodeView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        SGCodeTextView *tv = [[SGCodeTextView alloc] init];
        // UITextView默认上面有20的内边距，应该修改textContainerInset
        tv.textContainerInset = UIEdgeInsetsMake(0, 35, 0, 0);
        tv.editable = NO;
        tv.font = CodeFont;
        tv.backgroundColor = [UIColor whiteColor];
        tv.delegate = self;
        [self addSubview:tv];
        self.textView = tv;
        // 添加长按手势
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(press:)];
        press.minimumPressDuration = 0.1;
        [self addGestureRecognizer:press];
        // 添加通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexFinish) name:SGFileIndexFinishNotification object:nil];
    }
    return self;
}

- (void)press:(UILongPressGestureRecognizer *)ges{
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:{
            CGPoint pt = [ges locationInView:self];
            for (TextSegment *seg in self.segments) {
                CGRect rect = [self.textView convertRect:[self selectRect:self.textView range:seg.range] toView:self];
                if (rect.size.width == 0 || rect.size.height == 0) continue;
                if (CGRectContainsPoint(rect, pt)) {
                    self.textView.userInteractionEnabled = NO;
                    UIColor *coverColor = nil;
                    switch (seg.type) {
                        case TextSegmentTypeClass:
                            coverColor = RGBA(178, 215, 255, 0.6);
//                            NSLog(@"class name = %@",seg.text);
                            break;
                        case TextSegmentTypeMethod:
                            coverColor = RGBA(110, 110, 110, 0.6);
//                            NSLog(@"method key = %@",seg.text);
                            break;
                    }
                    if (!coverColor) {
                        continue;
                    }
                    UIView *cover = [[UIView alloc] initWithFrame:rect];
                    cover.layer.cornerRadius = 5;
                    cover.backgroundColor = coverColor;
                    cover.tag = CoverTag;
                    [self addSubview:cover];
                    [self parseSegment:seg];
                    return;
                }
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            self.textView.userInteractionEnabled = YES;
            // 为了能实现单击的响应，应该延时移除视图。
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                for (UIView *view in self.subviews) {
                    if (view.tag == CoverTag) {
                        [view removeFromSuperview];
                    }
                }
            });
            break;
        }
        default:
            break;
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    self.textView.frame = frame;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.index) {
        return;
    }
    self.textView.contentOffset = CGPointMake(0, -64);
}

- (NSString *)keywordRegex {
    static NSMutableString *match = nil;
    if (match == nil) {
        match = @"".mutableCopy;
        NSArray *keys = @[
                          // C
                            @"auto",@"short",@"int",@"long",@"float",@"double",@"char",@"struct",@"union",@"enum",@"typedef",
                            @"const",@"unsigned",@"signed",@"extern",@"register",@"static",@"volatile",@"void",@"if",@"else",
                            @"switch",@"for",@"do",@"while",@"goto",@"continue",@"break",@"default",@"sizeof",@"return",@"null",@"NULL",@"char16_t",@"char32_t",
                          /*
                           *    C++ language
                           */
                        @"asm",@"inline",@"typeid",@"dynamic_cast",@"typename",@"mutable",@"catch",@"explicit",@"namespace",@"static_cast",@"using",@"export",@"new",@"virtual",@"class",@"operator",@"private",@"template",@"const_cast",@"protected",@"this",@"wchar_t",@"public",@"throw",@"friend",@"true",@"delete",@"reinterpret_cast",@"try",@"nullptr",
                            /*
                             *  Unknown type
                             */
                            @"alignas",@"alignof",@"decltype",@"noexcept",@"thread_local",@"constexpr",@"explicit",@"restrict",@"_Imaginary",@"_Bool",@"_Complex",@"_Pragma",
                          /*
                           *    OC language
                           */
                            @"self",@"super",@"nil",@"id",@"BOOL",@"instancetype",
                            @"readwrite",@"readonly",@"assgin",@"copy",@"retain",@"strong",@"weak",@"atomic",@"nonatomic",
                            @"TRUE",@"FALSE",@"YES",@"NO"
                          ];
        [match appendString:RegexSegment(@"__asm__")];
        NSInteger cnt = keys.count;
        for (int i = 0; i < cnt; i++) {
            [match appendFormat:@"|%@",RegexSegment(keys[i])];
        }
    }
    [match appendFormat:@"|%@",@"<.*>|\'.*\'|\".*\""];
    return match;
}

- (void)setCode:(NSString *)code{
    if (code == nil) {
        return;
    }
    _code = code;
    self.textView.text = code;
    __weak typeof(self) weakSelf = self;
    [self renderText:code withCallback:^(NSAttributedString *attributedText) {
        weakSelf.textView.attributedText = attributedText;
    }];
}


- (void)renderText:(NSString *)text withCallback:(void (^)(NSAttributedString *attributedText))finish {
    __block NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    __block NSMutableArray<TextSegment *> *segments = [NSMutableArray array];
    SGIndexManager *mgr = [SGIndexManager sharedManager];
    [attributedText addAttribute:NSFontAttributeName value:CodeFont range:NSMakeRange(0, attributedText.length)];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        regex_barrier(^{
            [attributedText renderInRegex:@"[0-9]*" withColor:[UIColor blueColor]];
        });
        // block
        NSRange (^transformRangeBlock)(NSString *capStr, NSString *methodComp, NSRange captureRange) = ^(NSString *capStr, NSString *methodComp, NSRange captureRange) {
            NSRange subRange = [capStr rangeOfString:methodComp];
            NSRange finalRange = NSMakeRange(captureRange.location + subRange.location, subRange.length);
            return finalRange;
        };
        BOOL (^checkMethodCompValidBlock)(NSString *methodComp) = ^(NSString *methodComp) {
            for (NSUInteger i = 0; i < methodComp.length; i++) {
                if (!isalnum([methodComp characterAtIndex:i])) {
                    return NO;
                }
            }
            return YES;
        };
        // Method
        dispatch_barrier_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [text enumerateStringsMatchedByRegex:@"\\[.*\\]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                NSDictionary *methodAttrs = @{NSForegroundColorAttributeName:RGB(61, 30, 129), NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f]};
                NSString *capStr = *capturedStrings;
//                NSLog(@"%@",capStr);
                stack<char> charStack;
                string nameBuffer = "";
                stringstream ss;
                for (NSUInteger i = 0; i < capStr.length; i++) {
                    char c = [capStr characterAtIndex:i];
                    if (c != ']') {
                        charStack.push(c);
                    } else {
                        ss.str("");
                        while (!charStack.empty()) {
                            char top = charStack.top();
                            if (top != '[') {
                                ss << top;
                                charStack.pop();
                            } else {
                                charStack.pop();
                                break;
                            }
                        }
                        nameBuffer = ss.str();
                        reverse(nameBuffer.begin(), nameBuffer.end());
                        NSString *method = [NSString stringWithFormat:@"%s",nameBuffer.c_str()];
//                        NSLog(@"方法提取===>%@",method);
                        // 注意：如果有直接被括号包围的内容，如数组需要排除！ [a-z],@[a, b, c]等。
                        // 无参方法 UIColor whiteColor 左侧是类 右侧是方法
                        // 简单带参方法
                        // 1. super initWithFrame:frame 左侧不一定是类
                        // 2. initWithTarget:self action:@selector(press:)
                        
                        // 1.过滤非方法调用，主要是数组的语法糖和字符串中的闭合[]
                        //      1.1 排除以数字开头的语法糖
                        if (method.length && !isnumber([method characterAtIndex:0])) {
                        //      1.2 排除不包含空格的方法
                            if ([method rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound) {
                                NSString *methodKey = nil;
                        // 2.区分是否有参数，根据是否有冒号
                                if ([method rangeOfString:@":"].location == NSNotFound) {
                        //      2.1 无参方法
                                    NSArray *parts = [method componentsSeparatedByString:@" "];
                                    if (parts.count == 2) {
                                        methodKey = [parts lastObject];
                                        TextSegment *segment = [TextSegment new];
                                        segment.text = methodKey;
                                        segment.range = transformRangeBlock(capStr, methodKey, *capturedRanges);
                                        segment.type = TextSegmentTypeMethod;
                                        [segments addObject:segment];
                                        // 添加属性
                                        NSRange range = transformRangeBlock(capStr, methodKey, *capturedRanges);
                                        [attributedText addAttributes:methodAttrs range:range];
                                    }
                                } else {
                        //      2.2 带参方法
                        //      首先按照空格分离，只有含有冒号的才是方法的一部分
                                    NSArray *parts = [method componentsSeparatedByString:@" "];
                                    NSMutableString *methodWholeName = @"".mutableCopy;
                                    NSMutableArray *methodComps = @[].mutableCopy;
                                    // 第一个空格后面是方法，因此忽略第一部分
                                    for (NSUInteger i = 1; i < parts.count; i++) {
                                        NSString *methodPart = parts[i];
                                        NSArray *subPart = [methodPart componentsSeparatedByString:@":"];
                                        if (!subPart.count) continue;
                                        NSString *methodComp = [subPart firstObject];
                                        if (methodComp.length && !isalpha([methodComp characterAtIndex:0])) {
                                            continue;
                                        }
                                        if (!checkMethodCompValidBlock(methodComp)) continue;
//                                        NSLog(@"comp = %@",methodComp);
                                        // 添加属性
                                        NSRange range = transformRangeBlock(capStr, methodComp, *capturedRanges);
                                        [attributedText addAttributes:methodAttrs range:range];
                                        [methodWholeName appendFormat:@"%@:",methodComp];
                                        [methodComps addObject:methodComp];
                                    }
                                    methodKey = methodWholeName;
                                    for (NSUInteger i = 0; i < methodComps.count; i++) {
                                        TextSegment *segment = [TextSegment new];
                                        segment.text = methodKey;
                                        segment.range = transformRangeBlock(capStr, methodComps[i], *capturedRanges);
                                        segment.type = TextSegmentTypeMethod;
                                        [segments addObject:segment];
                                    }
                                }
                            } // method end
                        }
                    }
                }
            }];
        });
        // Class
        regex_barrier(^{
            [text enumerateStringsMatchedByRegex:@"[a-zA-Z][0-9a-zA-Z_+.]*" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                NSString *word = *capturedStrings;
                if ([word rangeOfString:@":"].location != NSNotFound) return;
                TextSegment *segment = [[TextSegment alloc] init];
                segment.text = word;
                segment.range = *capturedRanges;
                segment.type = TextSegmentTypeClass;
                [segments addObject:segment];
                if ([mgr indicesForClassNamed:word].count) {
                    [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:*capturedRanges];
                    [attributedText addAttribute:NSForegroundColorAttributeName value:RGB(78, 129, 136) range:*capturedRanges];
                }
            }];
        });
        // keywords
        regex_barrier(^{
            [text enumerateStringsMatchedByRegex:self.keywordRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                [attributedText addAttribute:NSForegroundColorAttributeName value:RGB(186, 44, 163) range:*capturedRanges];
            }];
        });
        // #
        regex_barrier(^{
            [attributedText renderInRegex:@"#[^ ]*" withColor:RGB(115, 70, 40)];
        });
        // objc @
        regex_barrier(^{
            [attributedText renderInRegex:@"@interface|@implementation|@end|@property|@selector|@dynamic|@synthesize|@protocol|@optional|@required|@encode" withColor:RGB(186, 44, 163)];
        });
        // objc string, string
        regex_barrier(^{
            [attributedText renderInRegex:@"@\"[^\"]*\"" withColor:RGB(209, 47, 27)];
        });
        /** 单行注释 和 多行注释 */
        regex_barrier(^{
            [text enumerateStringsMatchedByRegex:@"//.*|/\\*[\\s\\S]*?\\*/" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                [attributedText addAttribute:NSForegroundColorAttributeName value:RGB(59, 132, 104) range:*capturedRanges];
            }];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            self.segments = segments;
            if (finish) {
               finish(attributedText);
            }
        });
    });
}

- (void)setIndex:(SGIndex *)index {
    _index = index;
    NSData *codeData = [NSData dataWithContentsOfFile:index.filePath];
    self.code = [[NSString alloc] initWithData:codeData encoding:NSUTF8StringEncoding];
    [self.textView scrollRangeToVisible:index.range];
}

- (CGRect)selectRect:(UITextView *)textView range:(NSRange )range {
    UITextPosition *begin = textView.beginningOfDocument;
    UITextPosition *start = [textView positionFromPosition:begin offset:range.location];
    UITextPosition *end = [textView positionFromPosition:start offset:range.length];
    UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
    return [textView firstRectForRange:textRange];
}

// 触摸事件传递时会调用下面的方法询问是否处理
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return YES;
}

#pragma mark 解析单词
- (void)parseSegment:(TextSegment *)segment {
    NSString *word = segment.text;
    SGIndexManager *mgr = [SGIndexManager sharedManager];
    // 判断是否文件跳转
    if ([[SGFileUtil sharedUtil] isValidCodeFileNamed:word]) {
        // 文件跳转
        NSArray<SGFileIndex *> *fileIndices = [mgr indicesForFileNamed:word];
        if (fileIndices.count) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SGCodeViewShouldJumpNotification object:@{@"type":@"file", @"index":fileIndices}];
        } else {
            [MBProgressHUD showError:@"No such file"];
        }
        return;
    }
    switch (segment.type) {
        case TextSegmentTypeMethod: {
//            NSLog(@"method = %@",word);
            NSArray<SGMethodIndex *> *methodIndices = [mgr indicesForMethodKey:word];
            if (methodIndices.count) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SGCodeViewShouldJumpNotification object:@{@"type":@"method", @"index":methodIndices}];
            } else {
                [MBProgressHUD showError:@"?"];
            }
            break;
        }
        case TextSegmentTypeClass:{
//            NSLog(@"class = %@",word);
            NSArray<SGClassIndex *> *classIndices = [mgr indicesForClassNamed:word];
            if (classIndices.count) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SGCodeViewShouldJumpNotification object:@{@"type":@"class", @"index":classIndices}];
            } else {
                [MBProgressHUD showError:@"?"];
            }
            break;
        }
    }
}

#pragma mark UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

#pragma mark Notificatoin Callback
- (void)indexFinish {
    [self renderText:self.code withCallback:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
