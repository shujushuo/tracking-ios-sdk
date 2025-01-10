// TrackingSDK.m

#import "TrackingSDK.h"
#import "TrackingID.h"
#import "EventStorage.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "NetworkMonitor.h"
#import "DataUploader.h"
#import <Security/Security.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface TrackingSDK ()

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, strong) NSString *serverURL;
@property (nonatomic, strong) NSString *channelID;


@property (nonatomic, strong) NSString *cachedIDFA;
@property (nonatomic, strong) NSString *cachedIDFV;
@property (nonatomic, strong) NSString *cachedCAID;
@property (nonatomic, strong) NSString *cachedInstallID;
@property (nonatomic, strong) NSString *cachedDeviceModel;
@property (nonatomic, strong) NSString *cachedSystemVersion;
@property (nonatomic, strong) NSString *cachedBrand;
@property (nonatomic, strong) NSString *cachedPkgName;
@property (nonatomic, strong) NSString *cachedPkgVersion;

@end

@implementation TrackingSDK

+ (instancetype)sharedInstance {
    static TrackingSDK *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TrackingSDK alloc] init];
        [EventStorage sharedInstance];
    });
    return sharedInstance;
}

- (void)initialize:(NSString *)appID
         serverURL:(NSString *)url{
    [self initialize:appID serverURL:url channelID:@"DEFAULT"];
}

- (void)initialize:(NSString *)appID
         serverURL:(NSString *)serverURL
         channelID:(NSString *)channelID{
    self.appID = appID;
    self.serverURL = serverURL;
    self.channelID = channelID ?: @"DEFAULT";
    NSLog(@"初始化 - appID: %@, serverURL: %@, channelID: %@", self.appID, self.serverURL, self.channelID);
    NSDictionary *deviceInfo = [[TrackingID sharedInstance] getDeviceInfo];
    NSLog(@"deviceInfo: %@", deviceInfo);
    [[DataUploader sharedInstance] setServerURL:serverURL];
    [[NetworkMonitor sharedInstance] startMonitoring];
}

- (void)trackInstallEvent{
    [self trackEvent:@"install" xwho:nil xcontext:nil];
}

- (void)trackStartupEvent {
    [self trackEvent:@"startup" xwho:nil xcontext:nil];
}

- (void)trackRegisterEvent:(NSString *)xwho {
    [self trackEvent:@"register" xwho:xwho xcontext:nil];
}

- (void)trackLoginEvent:(NSString *)xwho {
    [self trackEvent:@"login" xwho:xwho xcontext:nil];
}

- (void)trackPaymentEvent:(NSString *)xwho
            transactionID:(NSString *)transactionID
              paymentType:(NSString *)paymentType
             currencyType:(CurrencyType)currencyType
           currencyAmount:(double)currencyAmount {
    [self trackPaymentEvent:xwho
              transactionID:transactionID
                paymentType:paymentType
               currencyType:currencyType
             currencyAmount:currencyAmount
              paymentStatus:true];
}

- (void)trackPaymentEvent:(NSString *)xwho
            transactionID:(NSString *)transactionID
              paymentType:(NSString *)paymentType
             currencyType:(CurrencyType)currencyType
           currencyAmount:(double)currencyAmount
            paymentStatus:(BOOL)paymentStatus {
    NSMutableDictionary *eventDetails = [NSMutableDictionary dictionary];
    eventDetails[@"transactionid"] = transactionID;
    eventDetails[@"paymenttype"] = paymentType;
    eventDetails[@"currencytype"] = @(currencyType);
    eventDetails[@"currencyamount"] = @(currencyAmount);
    eventDetails[@"paymentstatus"] = @(paymentStatus);
    
    [self trackEvent:@"payment" xwho:xwho xcontext:eventDetails];
}


- (void)trackEvent:(NSString *)xwhat
              xwho:(NSString *)xwho
          xcontext:(nullable NSDictionary *)additionalContext {
    if (!xwhat) {
        NSLog(@"事件名称是必需的。");
        return;
    }
    
    // 创建事件字典
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    
    // 基础字段
    event[@"appid"] = self.appID;
    event[@"xcontext"] = [self currentXContext];
    event[@"xwhat"] = xwhat;
    // 获取当前时间戳，并将其转换为整数（毫秒级）
    double timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    
    // 将时间戳添加到字典中
    event[@"xwhen"] = @( (uint64_t)timestamp );
    event[@"xwho"] = xwho;
    
    // 如果传入了额外的上下文，则将其合并到 xcontext 中
    if (additionalContext) {
        NSMutableDictionary *mergedContext = [event[@"xcontext"] mutableCopy];
        [mergedContext addEntriesFromDictionary:additionalContext];
        event[@"xcontext"] = [mergedContext copy];  // 更新 xcontext
    }
    [[EventStorage sharedInstance] saveEvent:event];
    
    [[DataUploader sharedInstance] uploadAllStoredEventsWithCompletion:^(BOOL success) {
        if (success) {
            NSLog(@"事件上传成功！");
        } else {
            NSLog(@"事件上传失败！");
        }
    }];
    // 保存事件
}


- (NSDictionary *)currentXContext {
    NSMutableDictionary *xcontext = [NSMutableDictionary dictionary];
    
    xcontext[@"brand"] = [TrackingID.sharedInstance getBrand];
    xcontext[@"model"] = [TrackingID.sharedInstance getDeviceModel];
    xcontext[@"os"] = @"ios";
    xcontext[@"os_version"] = [TrackingID.sharedInstance getSystemVersion];
    xcontext[@"idfa"] = [TrackingID.sharedInstance getIDFA];
    xcontext[@"idfv"] = [TrackingID.sharedInstance getIDFV];
    xcontext[@"caid"] = [TrackingID.sharedInstance getTrackingID];
    xcontext[@"installid"] = [TrackingID.sharedInstance getInstallID];
    xcontext[@"channelid"] = [self getChannelID];
    xcontext[@"pkg_name"] = [TrackingID.sharedInstance getPkgName];
    xcontext[@"pkg_version"] = [TrackingID.sharedInstance getPkgVersion];
    
    return [xcontext copy];
}


- (NSString *)getChannelID {
    // 检查 self.channelID 是否为 nil 或空字符串
    //    if (self.channelID == nil || [self.channelID isEqualToString:@""]) {
    //        return @"111";  // 如果 channelID 为空，返回默认值
    //    }
    NSLog(@"channelID: %@", self.channelID);
    return self.channelID ?: @"xxxx";  // 如果有值，返回实际的 channelID
}

@end
