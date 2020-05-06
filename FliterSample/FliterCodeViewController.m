//
//  ViewController.m
//  FliterSample
//
//  Created by apple on 2020/5/6.
//  Copyright © 2020 fly. All rights reserved.
//

#import "FliterCodeViewController.h"
#import "NSString+Handler.h"


@interface FliterCodeViewController()
//过滤关键词
@property (weak) IBOutlet NSTextField *prefixFiled;
//选择二进制目录
@property (weak) IBOutlet NSButton *chooseBtn;
//选择二进制文件label
@property (weak) IBOutlet NSTextField *tipLabel;
@property (weak) IBOutlet NSTextField *descLabel;
//开始过滤按钮
@property (weak) IBOutlet NSButton *startBtn;
//显示过滤内容
@property (weak) IBOutlet NSTextView *fliterView;
@property (nonatomic, copy) NSString *defautFliterSym;
@property (weak) IBOutlet NSTextField *showFliterSym;
@property (weak) IBOutlet NSButton *clearBtn;
@property (nonatomic, strong) NSProgressIndicator *indicator;
@property (weak) IBOutlet NSProgressIndicator *showIndicator;


@end


@implementation FliterCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //开始的时候tipLabel，fliterView，descLabel不显示
    [self preConfig];
   //添加通知
    [self addNotification];
}

- (void)preConfig{
    //当要输入过多的过滤词的时候，可自行手动在这里添加即可，界面的输入有限(有可能会导致审核拒审的关键词)
    self.defautFliterSym = @"UIWeb Pay Wechat Weixin alipay lezhong statusBar WKBrowsingContextController UIScrollViewPanGestureRecognizer LSApplicationWorkspace browsingContextController __NSArrayI UIStatusBarStringView _UIStatusBarWifiSignalView UIStatusBarDataNetworkItemView statusBarWindow _clearButton";
    self.tipLabel.hidden = YES;
    self.descLabel.hidden = YES;
    self.fliterView.hidden = YES;
    self.showFliterSym.hidden = YES;
    self.clearBtn.enabled = NO;
//    NSProgressIndicator *indicator = [[NSProgressIndicator alloc]initWithFrame:CGRectMake((screenW - 32) * 0.5, (screenH - 32)* 0.5, 32, 32)];
//    indicator.style = NSProgressIndicatorStyleSpinning;

      //这种方式只是给背景rect添加了背景色。

    self.showIndicator.wantsLayer = YES;

    self.showIndicator.layer.backgroundColor = [NSColor cyanColor].CGColor;

    
    self.showIndicator.hidden = YES;
    self.showIndicator.controlSize = NSControlSizeRegular;

    [self.showIndicator sizeToFit];



      


//     [self.showIndicator startAnimation:nil];
}
- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefixDidChange) name:NSControlTextDidChangeNotification object:self.prefixFiled];
}

- (void)prefixDidChange{
    NSString *text = [self.prefixFiled.stringValue sl_stringByRemovingSpace];
    self.startBtn.enabled = (text.length != 0) && (self.descLabel.stringValue.length != 0);
    self.clearBtn.enabled = self.startBtn.enabled;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//选择解压的二进制目录
- (IBAction)chooseFile:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.prompt = @"选择";
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = YES;
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK) return;
        
        self.descLabel.stringValue = openPanel.URLs.firstObject.path;
        self.descLabel.hidden = NO;
        self.tipLabel.hidden = NO;
        [self prefixDidChange];
    }];
}

- (IBAction)clear:(id)sender {
    self.prefixFiled.stringValue = @"";
    self.fliterView.string = @"";
    self.startBtn.enabled = NO;
    self.showFliterSym.stringValue = @"";
    self.clearBtn.enabled = NO;
    self.tipLabel.hidden = YES;
    self.descLabel.stringValue = @"";
}

/**
 设置特定文字的颜色

 @param color 搜索到的文字显示的颜色
 @param label 显示所有文字的控件
 @param font 搜索到的文字显示的大小
 @param text 搜索到的文字
 */
-(void)setColor:(NSColor *)color
          label:(NSTextField *)label
           font:(NSFont *)font
           text:(NSString *)text
{
    NSRange range = [label.stringValue rangeOfString:text];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.stringValue];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    label.attributedStringValue = str;
}

//开始过滤关键字
- (IBAction)startFliter:(id)sender {
    self.showIndicator.hidden = NO;
    [self.view.window.contentView addSubview:self.showIndicator];
    [self.showIndicator startAnimation:nil];
    self.prefixFiled.stringValue = [self.prefixFiled.stringValue stringByAppendingString:[NSString stringWithFormat:@" %@",self.defautFliterSym]];
    self.fliterView.string = @"";
    self.startBtn.enabled = NO;
    self.prefixFiled.enabled = NO;
    self.startBtn.enabled = NO;
    self.showFliterSym.hidden = NO;
    self.showFliterSym.stringValue = [NSString stringWithFormat:@"%@:%@",@"这次需要过滤的符号有",self.prefixFiled.stringValue];
    //获取前缀
    NSArray *prefixes = [self.prefixFiled.stringValue sl_componentsSeparatedBySpace];
//    NSString *samplePath = [[NSBundle mainBundle].bundleURL
//                           URLByAppendingPathComponent:@"script"
//                           isDirectory:YES].path;
    NSString *samplePath = [NSString stringWithFormat:@"%@/%@/%@/%@",[NSBundle mainBundle].bundlePath,@"Contents",@"Resources",@"script"];
    NSString *shellPath = [NSString stringWithFormat:@"%@/%@",samplePath,@"fliter.sh"];
    NSString *showContent = @"检测关键字结果:";
    BOOL isFliter = NO;
    for (int i = 0; i < prefixes.count; i++) {
       NSString *prefixFliter = [self invokingShellScriptAtPath:shellPath param1:self.descLabel.stringValue param2:prefixes[i]];
        if (prefixFliter.length > 0) {
             showContent = [showContent stringByAppendingString:@"\\n"];
             showContent = [showContent stringByAppendingString:prefixFliter];
            isFliter = YES;
        }
       
    }
    if (isFliter) {
         showContent = [showContent stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
       
           self.fliterView.textColor = [NSColor redColor];
    }else{
        showContent = @"恭喜你，该二进制暂时并没有发现涉及到的敏感词";
        self.fliterView.textColor = [NSColor blueColor];
    }
     self.fliterView.string = showContent;
   
    self.fliterView.hidden = NO;
    self.startBtn.enabled = YES;
    self.prefixFiled.enabled = YES;
    [self.showIndicator stopAnimation:nil];
    self.showIndicator.hidden = YES;
    
//    //处理进度
//    void(^progress)(NSString *) = ^(NSString *detail){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.tipLabel.stringValue = detail;
//        });
//    };
//    //处理结束
//    void(^completion)(NSString *) = ^(NSString *fileContent){
//
//    };
    
    
}


//Objective-C 调用shell脚本并返回结果
- (NSString *)invokingShellScriptAtPath:(NSString *)shellScriptPath param1:(NSString *)param1 param2:(NSString *)param2{
    NSTask *shellTask = [[NSTask alloc]init];
    [shellTask setLaunchPath:@"/bin/bash"];
    //shell 执行
    NSString *shellStr = [NSString stringWithFormat:@"sh %@ %@ %@",shellScriptPath,param1,param2];
    NSLog(@"shellStr:%@",shellStr);
    //-c 表示将后面的内容当成shellcode来执行
    [shellTask setArguments:[NSArray arrayWithObjects:@"-c",shellStr, nil]];
    
    NSPipe *pipe = [[NSPipe alloc]init];
    [shellTask setStandardOutput:pipe];
    [shellTask launch];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data = [file readDataToEndOfFile];
    NSString *strReturnFromShell = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"The return content from shell script is:%@",strReturnFromShell);
    
    return strReturnFromShell;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
