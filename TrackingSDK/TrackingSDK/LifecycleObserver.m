//
//  TrackingLifecycleObserver.m
//  Pods
//
//  Created by sylar on 2025/1/12.
//


#import "LifecycleObserver.h"
#import "DataUploader.h"
#import "Logger.h"
#import "TrackingSDK.h"

@implementation LifecycleObserver

+ (instancetype)sharedObserver {
    static LifecycleObserver *sharedObserver = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObserver = [[LifecycleObserver alloc] init];
    });
    return sharedObserver;
}

- (void)startObserving {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // 监听应用进入后台
    [nc addObserver:self
           selector:@selector(handleDidEnterBackground:)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
    
    // 监听应用变为活跃状态
//    [nc addObserver:self
//           selector:@selector(handleDidBecomeActive:)
//               name:UIApplicationWillEnterForegroundNotification
//             object:nil];
}

- (void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 处理通知的回调

- (void)handleDidEnterBackground:(NSNotification *)notification {
    // 当应用进入后台时执行的逻辑
    logMessage(@"应用已进入后台");
    
    [[DataUploader sharedInstance] uploadAllStoredEventsWithCompletion:^(BOOL success) {
        if (success) {
            logMessage(@"事件上传成功！");
        } else {
            logMessage(@"事件上传失败！");
        }
    }];
}

//
//- (void)handleDidBecomeActive:(NSNotification *)notification {
//    // 处理应用变为活跃时的事件，这里可认为是“启动”或“从后台恢复”
//    logMessage(@"应用已变为活跃状态，发送启动事件...");
//    // 在此处发送启动事件，例如调用服务器API或记录日志
//    [[TrackingSDK sharedInstance] trackStartupEvent];
//}

- (void)dealloc {
    [self stopObserving];
}

@end
