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
#import "SGFileIndex.h"
#import "SGGlobalCallbackManager.h"
#import "NSMutableAttributedString+SGExtension.h"

#define RegexSegment(param) [NSString stringWithFormat:@"\\b%@\\b",param]
#define CodeFont [UIFont systemFontOfSize:15]
#define CoverTag 1

@interface SGCodeView () <UITextViewDelegate>

@property (nonatomic, weak) SGCodeTextView *textView;

@end

@implementation SGCodeView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        SGCodeTextView *tv = [[SGCodeTextView alloc] init];
        // UITextView默认上面有20的内边距，应该修改textContainerInset
        tv.textContainerInset = UIEdgeInsetsMake(0, 35, 0, 5);
        tv.editable = NO;
        tv.font = CodeFont;
        tv.backgroundColor = [UIColor whiteColor];
        tv.delegate = self;
        [self addSubview:tv];
        self.textView = tv;
        // 添加长按手势
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(press:)];
        press.minimumPressDuration = 0.2;
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
                    UIView *cover = [[UIView alloc] initWithFrame:rect];
                    cover.layer.cornerRadius = 5;
                    cover.backgroundColor = [UIColor colorWithRed:178/255.0 green:215/255.0 blue:255/255.0 alpha:0.8];
                    cover.tag = CoverTag;
                    [self addSubview:cover];
                    [self jumpWithText:seg.text];
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
    self.textView.frame = self.bounds;
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
    [self renderText:code WithCallback:^(NSAttributedString *attributedText) {
        weakSelf.textView.attributedText = attributedText;
    }];
    
}


- (void)renderText:(NSString *)text WithCallback:(void (^)(NSAttributedString *attributedText))finish {
    __block NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    __block NSMutableArray<TextSegment *> *segments = [NSMutableArray array];
    SGIndexManager *mgr = [SGIndexManager sharedManager];
    [attributedText addAttribute:NSFontAttributeName value:CodeFont range:NSMakeRange(0, attributedText.length)];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        regex_barrier(^{
            [attributedText renderInRegex:@"[0-9]*" withColor:[UIColor blueColor]];
        });
        regex_barrier(^{
            [text enumerateStringsMatchedByRegex:@"[a-zA-Z][0-9a-zA-Z_+.]*" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                NSString *word = *capturedStrings;
                TextSegment *segment = [[TextSegment alloc] init];
                segment.text = word;
                segment.range = *capturedRanges;
                segment.special = YES;
                [segments addObject:segment];
                if ([mgr indexForClassNamed:word]) {
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

- (void)setIndex:(SGFileIndex *)index {
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

- (void)jumpWithText:(NSString *)segText {
    if ([segText hasSuffix:@".h"]) {
        NSArray *indexes = [[SGIndexManager sharedManager] indexForImportFile:segText];
        if (indexes == nil) {
            [MBProgressHUD showError:@"?"];
            return;
        }
        NSNotification *nof = [NSNotification notificationWithName:SGCodeViewNotification object:nil userInfo:@{@"type":@"file",@"indexes":indexes}];
        [[NSNotificationCenter defaultCenter] postNotification:nof];
    }else{
        NSArray *indexes = [[SGIndexManager sharedManager] indexForMethod:segText];
        if (indexes == nil) {
            [MBProgressHUD showError:@"?"];
            return;
        }
        NSNotification *nof = [NSNotification notificationWithName:SGCodeViewNotification object:nil userInfo:@{@"type":@"method",@"indexes":indexes}];
        [[NSNotificationCenter defaultCenter] postNotification:nof];
    }
}

// 触摸事件传递时会调用下面的方法询问是否处理
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return YES;
}

#pragma mark Notificatoin Callback
- (void)indexFinish {
    [self renderText:self.code WithCallback:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
