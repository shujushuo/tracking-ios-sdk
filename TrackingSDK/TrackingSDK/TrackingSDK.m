// TrackingSDK.m

#import "TrackingSDK.h"
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
NSString *unknwo_idfa = @"00000000-0000-0000-0000-000000000000";

+ (instancetype)sharedInstance {
    static TrackingSDK *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TrackingSDK alloc] init];
    });
    return sharedInstance;
}

- (void)initialize:(NSString *)appID
         serverURL:(NSString *)url{
    [self initialize:appID serverURL:url channelID:nil];
}

- (void)initialize:(NSString *)appID
         serverURL:(NSString *)serverURL
         channelID:(NSString *)channelID{
    self.appID = appID;
    self.serverURL = serverURL;
    self.channelID = channelID ?: @"DEFAULT";
    NSLog(@"初始化 - appID: %@, serverURL: %@, channelID: %@", self.appID, self.serverURL, self.channelID);
    
    [[DataUploader sharedInstance] setServerURL:serverURL];
    [[NetworkMonitor sharedInstance] startMonitoring];
}

- (void)trackInstallEvent{
    [self trackEvent:@"user_signup" xwho:nil xcontext:nil];
}

- (void)trackStartupEvent {
    [self trackEvent:@"user_signup" xwho:nil xcontext:nil];
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
    event[@"xwhen"] = @([[NSDate date] timeIntervalSince1970] * 1000);
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
    
    xcontext[@"brand"] = [self getBrand];
    xcontext[@"model"] = [self getDeviceModel];
    xcontext[@"os"] = @"ios";
    xcontext[@"os_version"] = [self getSystemVersion];
    xcontext[@"idfa"] = [self getIDFA];
    xcontext[@"idfv"] = [self getIDFV];
    xcontext[@"caid"] = [self getCAID];
    xcontext[@"installid"] = [self getInstallID];
    xcontext[@"channelid"] = [self getChannelID];
    xcontext[@"pkg_name"] = [self getPkgName];
    xcontext[@"pkg_version"] = [self getPkgVersion];
    
    // 获取包名
    
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

// 获取设备型号
- (NSString *)getDeviceModel {
    if (!_cachedDeviceModel) {
        // 转换硬件标识符为字符串
        struct utsname systemInfo;
        uname(&systemInfo);
        _cachedDeviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    }
    return _cachedDeviceModel;
}

- (NSString *)getSystemVersion {
    if (!_cachedSystemVersion) {
        _cachedSystemVersion = [[UIDevice currentDevice] systemVersion];
    }
    return _cachedSystemVersion;
}

// 获取IDFA
- (NSString *)getIDFA {
    if (!_cachedIDFA) {
        _cachedIDFA = unknwo_idfa;
        if (@available(iOS 14, *)) {
            ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                // 如果授权，获取IDFA
                _cachedIDFA = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            }
        } else {
            // 早期iOS版本，不支持AppTrackingTransparency
            _cachedIDFA = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
        }
    }
    return _cachedIDFA;
}

// 获取IDFV
- (NSString *)getIDFV {
    if (!_cachedIDFV) {
        _cachedIDFV = [[UIDevice currentDevice].identifierForVendor UUIDString] ?: @"unknown";
    }
    return _cachedIDFV;
}

// 获取IDFV
- (NSString *)getCAID {
    if (!_cachedCAID) {
        _cachedCAID = @"unknown";
    }
    return _cachedCAID;
}

// 获取IDFV
- (NSString *)getBrand {
    return @"apple";
}

- (NSString *)getInstallID {
    _cachedInstallID = [self getFromKeychainForKey:@"installID"];
    if (!_cachedInstallID) {
        NSString *deviceID = [self getIDFA];
        if (deviceID.length == 0 || [deviceID  isEqual: unknwo_idfa]) {
            // 如果 IDFA 为空，则使用 CAID
            deviceID = [self getCAID];
            if (deviceID.length == 0 || [deviceID isEqual: @"unknown"]) {
                // 如果 CAID 为空，则使用 IDFV
                deviceID = [self getIDFV];
            }
        }
        NSString *timestamp = [NSString stringWithFormat:@"%lld", (long long)([[NSDate date] timeIntervalSince1970] * 1000)];
        _cachedInstallID = [NSString stringWithFormat:@"%@_%@", timestamp, deviceID];
        [self saveToKeychain:_cachedInstallID forKey:@"installID"];
    }
    return _cachedInstallID;
}

- (NSString *)getPkgName {
    if (!_cachedPkgName) {
        _cachedPkgName = [[NSBundle mainBundle] bundleIdentifier];
    }
    return _cachedPkgName;
}

- (NSString *)getPkgVersion {
    if (!_cachedPkgVersion) {
        _cachedPkgVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    }
    return _cachedPkgVersion;
}

- (NSString *)getChannelID {
    // 检查 self.channelID 是否为 nil 或空字符串
    //    if (self.channelID == nil || [self.channelID isEqualToString:@""]) {
    //        return @"111";  // 如果 channelID 为空，返回默认值
    //    }
    NSLog(@"channelID: %@", self.channelID);
    return self.channelID ?: @"xxxx";  // 如果有值，返回实际的 channelID
}

// 从钥匙链读取数据
- (NSString *)getFromKeychainForKey:(NSString *)key {
    NSLog(@"getFromKeychainForKey");
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrAccount] = key;
    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    
    CFDataRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    
    if (status == errSecSuccess && result != NULL) {
        NSData *data = (__bridge_transfer NSData *)result;
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return dataString;
    }
    
    return nil;
}

// 存储数据到钥匙链
- (void)saveToKeychain:(NSString *)data forKey:(NSString *)key {
    NSLog(@"saveToKeychain");
    
    NSData *dataToStore = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrAccount] = key;
    query[(__bridge id)kSecValueData] = dataToStore;
    
    // 删除现有的钥匙链数据
    SecItemDelete((__bridge CFDictionaryRef)query);
    
    // 添加新的钥匙链数据
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    if (status != errSecSuccess) {
        NSLog(@"Failed to save data to keychain: %d", (int)status);
    }
}

@end
