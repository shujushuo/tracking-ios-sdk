// TrackingSDK.h

#import <Foundation/Foundation.h>
#import "NetworkMonitor.h"
#import "DataUploader.h"
#import "EventStorage.h"

@interface TrackingSDK : NSObject

+ (instancetype)sharedInstance;

// 初始化 SDK，设置 AppID 和服务器 URL
- (void)initializeWithAppID:(NSString *)appID
                 serverURL:(NSString *)url;

// 记录事件，自动包含全局属性
- (void)trackEvent:(NSString *)eventName;

@end
