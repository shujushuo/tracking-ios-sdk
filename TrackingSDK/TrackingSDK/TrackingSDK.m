// TrackingSDK.m

#import "TrackingSDK.h"
#import "EventStorage.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "NetworkMonitor.h"
#import "DataUploader.h"


@interface TrackingSDK ()

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, strong) NSString *serverURL;

@end

@implementation TrackingSDK

+ (instancetype)sharedInstance {
    static TrackingSDK *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TrackingSDK alloc] init];
    });
    return sharedInstance;
}

- (void)initializeWithAppID:(NSString *)appID
                 serverURL:(NSString *)url {
    self.appID = appID;
    self.serverURL = url;
    
    [[DataUploader sharedInstance] setServerURL:url];
    [[NetworkMonitor sharedInstance] startMonitoring];
}

- (void)trackEvent:(NSString *)eventName {
    if (!eventName) {
        NSLog(@"事件名称是必需的。");
        return;
    }
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    event[@"appid"] = self.appID ? self.appID : @"";
    event[@"xcontext"] = [self currentXContext];
    event[@"xwhat"] = eventName;
    event[@"xwhen"] = @([[NSDate date] timeIntervalSince1970] * 1000); // 毫秒时间戳
    
    [[EventStorage sharedInstance] saveEvent:event];
}

- (NSDictionary *)currentXContext {
    NSMutableDictionary *xcontext = [NSMutableDictionary dictionary];
    
    // 获取 IDFA
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        if (idfa) {
            xcontext[@"idfa"] = idfa;
        }
    } else {
        xcontext[@"idfa"] = @"";
    }
    
    // 获取 IDFV
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (idfv) {
        xcontext[@"idfv"] = idfv;
    } else {
        xcontext[@"idfv"] = @"";
    }
    
    // 获取 CAID（假设是自定义属性，需要根据实际情况实现）
    NSString *caid = @"example_caid"; // 替换为实际获取 CAID 的方法
    xcontext[@"caid"] = caid ? caid : @"";
    
    // 获取 InstallID（假设是自定义属性，需要根据实际情况实现）
    NSString *installid = @"example_installid"; // 替换为实际获取 InstallID 的方法
    xcontext[@"installid"] = installid ? installid : @"";
    
    // 获取操作系统
    xcontext[@"os"] = @"ios";
    
    // 获取操作系统版本
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    xcontext[@"os_version"] = osVersion ? osVersion : @"";
    
    // 获取设备品牌
    xcontext[@"brand"] = @"apple"; // iOS 设备品牌固定为 Apple
    
    // 获取渠道 ID（假设是自定义属性，需要根据实际情况实现）
    NSString *channelid = @"example_channelid"; // 替换为实际获取 ChannelID 的方法
    xcontext[@"channelid"] = channelid ? channelid : @"";
    
    // 获取设备型号
    NSString *model = [self deviceModel];
    xcontext[@"model"] = model ? model : @"";
    
    // 获取包名
    NSString *pkgName = [[NSBundle mainBundle] bundleIdentifier];
    xcontext[@"pkg_name"] = pkgName ? pkgName : @"";
    
    return [xcontext copy];
}

// 辅助方法：获取设备型号
- (NSString *)deviceModel {
    // 获取设备型号的具体实现，可以使用 sys/utsname.h
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    return deviceModel ? deviceModel : @"";
}

@end
