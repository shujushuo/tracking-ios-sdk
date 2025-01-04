// NetworkMonitor.m

#import "NetworkMonitor.h"
#import "Reachability.h"
#import "DataUploader.h"

@interface NetworkMonitor ()

@property (nonatomic, strong) Reachability *reachability;

@end

@implementation NetworkMonitor

+ (instancetype)sharedInstance {
    static NetworkMonitor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkMonitor alloc] init];
    });
    return sharedInstance;
}

- (void)startMonitoring {
    self.reachability = [Reachability reachabilityForInternetConnection];
    
    __weak typeof(self) weakSelf = self;
    self.reachability.reachableBlock = ^(Reachability *reach) {
        NSLog(@"Network is reachable");
        // 网络连接恢复，上传存储的事件
        [weakSelf uploadStoredEvents];
    };
    
    self.reachability.unreachableBlock = ^(Reachability *reach) {
        NSLog(@"No network connection.");
        // 网络连接不可用，可以在这里处理其他逻辑
    };
    
    [self.reachability startNotifier];
}

- (void)stopMonitoring {
    [self.reachability stopNotifier];
}

- (void)uploadStoredEvents {
    [[DataUploader sharedInstance] uploadAllStoredEventsWithCompletion:^(BOOL success) {
        if (success) {
            NSLog(@"All stored events uploaded successfully.");
        } else {
            NSLog(@"Some events failed to upload.");
        }
    }];
}

@end
