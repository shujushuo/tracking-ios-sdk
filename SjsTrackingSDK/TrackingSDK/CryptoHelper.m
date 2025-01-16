#import "CryptoHelper.h"
#import <CommonCrypto/CommonCryptor.h>
#import "Logger.h"

@implementation CryptoHelper



+ (NSString *)AES128EncryptData:(NSData *)data withKey:(NSString *)key iv:(NSString *)iv{
    // 确保密钥长度为 16 字节（128 位）
    char keyBytes[kCCKeySizeAES128+1];
    bzero(keyBytes, sizeof(keyBytes));
    [key getCString:keyBytes maxLength:sizeof(keyBytes) encoding:NSUTF8StringEncoding];
    
    // 确保 IV 长度为 16 字节
    char ivBytes[kCCBlockSizeAES128+1];
    bzero(ivBytes, sizeof(ivBytes));
    [iv getCString:ivBytes maxLength:sizeof(ivBytes) encoding:NSUTF8StringEncoding];
    
    size_t dataOutLength = 0;
    NSMutableData *resultData = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
    
    CCCryptorStatus status = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                     keyBytes, kCCKeySizeAES128, ivBytes,
                                     data.bytes, data.length,
                                     resultData.mutableBytes, resultData.length,
                                     &dataOutLength);
    
    if (status == kCCSuccess) {
        [resultData setLength:dataOutLength];
        // 调试日志
        logMessage(@"Encrypted Data: %@", [resultData base64EncodedStringWithOptions:0]);
        return [resultData base64EncodedStringWithOptions:0];
    }
    
    // 返回 nil 如果加密失败
    logMessage(@"Encryption failed with status: %d", status);
    return nil;
}

+ (NSString *)AES128DecryptData:(NSData *)data withKey:(NSString *)key  iv:(NSString *)iv{
    // 确保密钥长度为 16 字节（128 位）
    char keyBytes[kCCKeySizeAES128+1];
    bzero(keyBytes, sizeof(keyBytes));
    [key getCString:keyBytes maxLength:sizeof(keyBytes) encoding:NSUTF8StringEncoding];
    
    // 确保 IV 长度为 16 字节
    char ivBytes[kCCBlockSizeAES128+1];
    bzero(ivBytes, sizeof(ivBytes));
    [iv getCString:ivBytes maxLength:sizeof(ivBytes) encoding:NSUTF8StringEncoding];
    
    size_t dataOutLength = 0;
    NSMutableData *resultData = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
    
    CCCryptorStatus status = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                     keyBytes, kCCKeySizeAES128, ivBytes,
                                     data.bytes, data.length,
                                     resultData.mutableBytes, resultData.length,
                                     &dataOutLength);
    
    // 如果解密成功
      if (status == kCCSuccess) {
          [resultData setLength:dataOutLength];
          
          // 将解密后的数据转为 NSString（假设是 UTF-8 编码的字符串）
          NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
          
          // 如果转换为 UTF-8 字符串成功
          if (resultString) {
              logMessage(@"AES128 Decrypt Result: %@", resultString);
              return resultString;
          } else {
              // 如果解密后的数据无法转为 UTF-8 字符串
              logMessage(@"Decrypted data is not valid UTF-8: %@", resultData);
          }
      } else {
          logMessage(@"AES128 decryption failed with status: %d", status);
      }
      
    return nil;
}

@end
