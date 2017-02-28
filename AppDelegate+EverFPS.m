//
//  AppDelegate+EverFPS.m
//  BaichengVisa_v121
//
//  Created by Ever on 17/2/28.
//  Copyright © 2017年 Beijing Byecity International Travel CO., Ltd. All rights reserved.
//

#import "AppDelegate+EverFPS.h"
#import <objc/runtime.h>

#define kEverMonitorFPSLblTag (4713297)

static CADisplayLink *_everMonitorDisplayLink;

@implementation AppDelegate (EverFPS)

+ (void)load
{
#ifdef DEBUG
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];
        Method m1 = class_getInstanceMethod(cls, @selector(application:didFinishLaunchingWithOptions:));
        Method m2 = class_getInstanceMethod(cls, @selector(applicationEverFPS:didFinishLaunchingWithOptions:));
        method_exchangeImplementations(m1, m2);
    });
#endif
}

- (BOOL)applicationEverFPS:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL bl = [self applicationEverFPS:application didFinishLaunchingWithOptions:launchOptions];
    UILabel *fpsLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 60, 20)];
    fpsLbl.layer.cornerRadius = 3;
    fpsLbl.layer.masksToBounds = YES;
    fpsLbl.backgroundColor = [UIColor greenColor];
    fpsLbl.textColor = [UIColor redColor];
    fpsLbl.tag = kEverMonitorFPSLblTag;
    fpsLbl.text = @"FPS:60";
    [self.window addSubview:fpsLbl];
    
    _everMonitorDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(monitorFPS)];
    _everMonitorDisplayLink.frameInterval = 1;
    [_everMonitorDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    return bl;
}

- (void)monitorFPS
{
    static CFTimeInterval _lastTimestamp = 0;
    if (_lastTimestamp == 0) {
        _lastTimestamp = _everMonitorDisplayLink.timestamp;
        return;
    }
    
    static NSUInteger _count = 0;
    _count++;
    
    CFTimeInterval delta = _everMonitorDisplayLink.timestamp - _lastTimestamp;
    if (delta < 1) {
        return;
    }
    _lastTimestamp = _everMonitorDisplayLink.timestamp;
    float fps = _count / delta;
    _count = 0;
    
    UILabel *fpsLbl = [self.window viewWithTag:kEverMonitorFPSLblTag];
    fpsLbl.text = [NSString stringWithFormat:@"FPS:%d",(int)round(fps)];
    
    if (fps < 45) {
        NSLog(@"EVER_FPS_CALL_STACK_SYMBOL:%@",[NSThread callStackSymbols]);
    }
}

@end
