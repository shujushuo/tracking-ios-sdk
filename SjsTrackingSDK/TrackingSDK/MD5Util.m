//
//  CAIDMD5Util.m
//  Pods
//
//  Created by sylar on 2025/1/9.
//

#import "MD5Util.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation CAIDMD5Util

+ (NSString *)md5HexDigest:(NSString *)input
{
    if (!input || input.length == 0) {
        return nil; // 或者返回空字符串 @""
    }
    
    // 将字符串转换为 UTF-8 编码的 NSData
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH]; // MD5摘要的长度=16字节
    
    // 进行 MD5 运算
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    // 将结果转换为十六进制字符串
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return [output copy];
}

@end
