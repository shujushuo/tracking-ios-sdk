// TrackingSDK.m

#import "TrackingSDK.h"
#import "TrackingID.h"
#import "EventStorage.h"
#import "DataUploader.h"
#import "Logger.h"
#import "LifecycleObserver.h"

#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <Security/Security.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface TrackingSDK ()

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, strong) NSString *serverURL;
@property (nonatomic, strong) NSString *channelID;
@end

@implementation TrackingSDK

+ (instancetype)sharedInstance {
    static TrackingSDK *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TrackingSDK alloc] init];
        [EventStorage sharedInstance];
        [[LifecycleObserver sharedObserver] startObserving];

    });
    return sharedInstance;
}

- (void)setLoggingEnabled:(BOOL)enabled {
    setLoggingEnabled(enabled); // 启用日志
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
    logMessage(@"初始化 - appID: %@, serverURL: %@, channelID: %@", self.appID, self.serverURL, self.channelID);
    NSDictionary *deviceInfo = [[TrackingID sharedInstance] getDeviceInfo];
    logMessage(@"deviceInfo: %@", deviceInfo);
    [[DataUploader sharedInstance] setServerURL:serverURL];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 检查是否已经跟踪过安装事件
    if (![defaults boolForKey:@"hasTrackedInstallEvent"]) {
        [self trackInstallEvent];
        [defaults setBool:YES forKey:@"hasTrackedInstallEvent"];
        [defaults synchronize];
        logMessage(@"第一次安装后启动，上报install");
    }else{
        logMessage(@"已经不是第一次安装后启动，不上报isntall");
    }
    [self trackStartupEvent];
}

- (void)unset:(NSString *)appID
         serverURL:(NSString *)url{
    [[LifecycleObserver sharedObserver] stopObserving];
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
    
    NSString *currencyTypeString = [self stringFromCurrencyType:currencyType];
    NSMutableDictionary *eventDetails = [NSMutableDictionary dictionary];
    eventDetails[@"transactionid"] = transactionID;
    eventDetails[@"paymenttype"] = paymentType;
    eventDetails[@"currencytype"] = currencyTypeString;
    eventDetails[@"currencyamount"] = @(currencyAmount);
    eventDetails[@"paymentstatus"] = @(paymentStatus);
    
    [self trackEvent:@"payment" xwho:xwho xcontext:eventDetails];
}


- (void)trackEvent:(NSString *)xwhat
              xwho:(NSString *)xwho
          xcontext:(nullable NSDictionary *)additionalContext {
    if (!xwhat) {
        logMessage(@"事件名称是必需的。");
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
            logMessage(@"事件上传成功！");
        } else {
            logMessage(@"事件上传失败！");
        }
    }];
    // 保存事件
}


- (NSDictionary *)currentXContext {
    NSMutableDictionary *xcontext = [NSMutableDictionary dictionary];
    
    xcontext[@"brand"] = [TrackingID.sharedInstance getBrand];
    xcontext[@"model"] = [TrackingID.sharedInstance getModel];
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
    // 如果有值，返回实际的 channelID
    return self.channelID ?: @"DEFAULT";
}

- (NSString *)stringFromCurrencyType:(CurrencyType)currencyType {
    switch (currencyType) {
        case CurrencyTypeUSD:
            return @"USD";
        case CurrencyTypeEUR:
            return @"EUR";
        case CurrencyTypeJPY:
            return @"JPY";
        case CurrencyTypeGBP:
            return @"GBP";
        case CurrencyTypeAUD:
            return @"AUD";
        case CurrencyTypeCAD:
            return @"CAD";
        case CurrencyTypeCHF:
            return @"CHF";
        case CurrencyTypeCNY:
            return @"CNY";
        case CurrencyTypeSEK:
            return @"SEK";
        case CurrencyTypeNZD:
            return @"NZD";
        case CurrencyTypeMXN:
            return @"MXN";
        case CurrencyTypeSGD:
            return @"SGD";
        case CurrencyTypeHKD:
            return @"HKD";
        case CurrencyTypeNOK:
            return @"NOK";
        case CurrencyTypeKRW:
            return @"KRW";
        case CurrencyTypeTRY:
            return @"TRY";
        case CurrencyTypeRUB:
            return @"RUB";
        case CurrencyTypeINR:
            return @"INR";
        case CurrencyTypeBRL:
            return @"BRL";
            // 在此处添加其他货币类型的处理
        default:
            return @"Unknown";
    }
}

@end
