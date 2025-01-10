// TrackingSDK.h

#import <Foundation/Foundation.h>
#import "TrackingID.h"

@interface TrackingSDK : NSObject

typedef NS_ENUM(NSInteger, CurrencyType) {
    CurrencyTypeUSD,
    CurrencyTypeEUR,
    CurrencyTypeCNY,
    CurrencyTypeJPY,
    // 你可以根据需要继续添加更多货币类型
};

+ (instancetype _Nonnull )sharedInstance;

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
