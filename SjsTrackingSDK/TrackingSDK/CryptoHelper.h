#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CryptoHelper : NSObject

// AES 加密
+ (NSString *)AES128EncryptData:(NSData *)data withKey:(NSString *)key iv:(NSString *)iv;
// AES 解密
+ (NSString *)AES128DecryptData:(NSData *)data withKey:(NSString *)key iv:(NSString *)iv;
@end

NS_ASSUME_NONNULL_END
