// TrackingSDK.h

#import <Foundation/Foundation.h>


@interface TrackingSDK : NSObject

+ (instancetype)sharedInstance;

// 初始化 SDK，设置 AppID 和服务器 URL
- (void)initializeWithAppID:(NSString *)appID
                 serverURL:(NSString *)url;
- (void)initializeWithAppID:(NSString *)appID
                 serverURL:(NSString *)url
                 channelID:(NSString *)channelID;
// 记录事件，自动包含全局属性
- (void)trackEvent:(NSString *)eventName;

@end
