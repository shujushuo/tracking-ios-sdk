// TrackingSDK.h

#import <Foundation/Foundation.h>
#import "TrackingID.h"

@interface TrackingSDK : NSObject


typedef NS_ENUM(NSInteger, CurrencyType) {
    CurrencyTypeUSD,  // 美元
    CurrencyTypeEUR,  // 欧元
    CurrencyTypeJPY,  // 日元
    CurrencyTypeGBP,  // 英镑
    CurrencyTypeAUD,  // 澳大利亚元
    CurrencyTypeCAD,  // 加拿大元
    CurrencyTypeCHF,  // 瑞士法郎
    CurrencyTypeCNY,  // 人民币
    CurrencyTypeSEK,  // 瑞典克朗
    CurrencyTypeNZD,  // 新西兰元
    CurrencyTypeMXN,  // 墨西哥比索
    CurrencyTypeSGD,  // 新加坡元
    CurrencyTypeHKD,  // 港币
    CurrencyTypeNOK,  // 挪威克朗
    CurrencyTypeKRW,  // 韩元
    CurrencyTypeTRY,  // 土耳其里拉
    CurrencyTypeRUB,  // 俄罗斯卢布
    CurrencyTypeINR,  // 印度卢比
    CurrencyTypeBRL,  // 巴西雷亚尔
    // 根据需要继续添加更多货币
};



+ (instancetype _Nonnull )sharedInstance;

- (void)setLoggingEnabled:(BOOL)enabled;

//- (void)logMessage:(NSString *_Nonnull)format, ... NS_FORMAT_FUNCTION(1,2);

// 初始化 SDK，设置 AppID 和服务器 URL
- (void)initialize:(NSString *_Nonnull)appID
         serverURL:(NSString *_Nonnull)url;
- (void)initialize:(NSString *_Nonnull)appID
         serverURL:(NSString *_Nonnull)url
         channelID:(NSString *_Nonnull)channelID;

- (void)trackInstallEvent;

- (void)trackStartupEvent;

- (void)trackRegisterEvent:(NSString *_Nonnull)xwho;

- (void)trackLoginEvent:(NSString *_Nonnull)xwho;

- (void)trackPaymentEvent:(NSString *_Nonnull)xwho
            transactionID:(NSString *_Nonnull)transactionID
              paymentType:(NSString *_Nonnull)paymentType
             currencyType:(CurrencyType)currencyType
           currencyAmount:(double)currencyAmount
            paymentStatus:(BOOL)paymentStatus;

- (void)trackPaymentEvent:(NSString *_Nonnull)xwho
            transactionID:(NSString *_Nonnull)transactionID
              paymentType:(NSString *_Nonnull)paymentType
             currencyType:(CurrencyType)currencyType
           currencyAmount:(double)currencyAmount;

// 记录事件，自动包含全局属性
- (void)trackEvent:(NSString *_Nonnull)xwhat
              xwho:(nullable NSString *)xwho
          xcontext:(nullable NSDictionary *)additionalContext;

@end
