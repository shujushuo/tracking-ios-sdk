// TrackingSDK.h

#import <Foundation/Foundation.h>


@interface TrackingSDK : NSObject

typedef NS_ENUM(NSInteger, CurrencyType) {
    CurrencyTypeUSD,
    CurrencyTypeEUR,
    CurrencyTypeCNY,
    CurrencyTypeJPY,
    // 你可以根据需要继续添加更多货币类型
};

+ (instancetype)sharedInstance;

// 初始化 SDK，设置 AppID 和服务器 URL
- (void)initialize:(NSString *)appID
         serverURL:(NSString *)url;
- (void)initialize:(NSString *)appID
         serverURL:(NSString *)url
         channelID:(NSString *)channelID;

- (void)trackInstallEvent;

- (void)trackStartupEvent;

- (void)trackRegisterEvent:(NSString *)xwho;

- (void)trackLoginEvent:(NSString *)xwho;

- (void)trackPaymentEvent:(NSString *)xwho
            transactionID:(NSString *)transactionID
              paymentType:(NSString *)paymentType
             currencyType:(CurrencyType)currencyType
           currencyAmount:(double)currencyAmount
            paymentStatus:(BOOL)paymentStatus;

- (void)trackPaymentEvent:(NSString *)xwho
            transactionID:(NSString *)transactionID
              paymentType:(NSString *)paymentType
             currencyType:(CurrencyType)currencyType
           currencyAmount:(double)currencyAmount;

// 记录事件，自动包含全局属性
- (void)trackEvent:(NSString *_Nonnull)xwhat
              xwho:(nullable NSString *)xwho
            xcontext:(nullable NSDictionary *)additionalContext;
// 获取设备型号
- (NSString *_Nonnull)getDeviceModel;

// 获取IDFA
- (NSString *_Nonnull)getIDFA;

// 获取IDFV
- (NSString *_Nonnull)getIDFV;

// 获取IDFV
- (NSString *_Nonnull)getCAID;

// 获取Install ID
- (NSString *_Nonnull)getInstallID;

// 获取品牌
- (NSString *_Nonnull)getBrand;

// 获取系统版本
- (NSString *_Nonnull)getSystemVersion;

// 获取包名
- (NSString *_Nonnull)getPkgName;

// 获取包版本
- (NSString *_Nonnull)getPkgVersion;

// 获取SDK初始化的渠道ID
- (NSString *_Nonnull)getChannelID;
@end
