//
//  CAIDMD5Util.h
//  Pods
//
//  Created by sylar on 2025/1/9.
//

#import <Foundation/Foundation.h>

@interface CAIDMD5Util : NSObject

/// 对输入字符串进行 MD5 运算，并返回十六进制格式的 MD5 摘要
+ (NSString *)md5HexDigest:(NSString *)input;

@end
