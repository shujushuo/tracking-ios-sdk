#import <Foundation/Foundation.h>

// 设置日志状态
void setLoggingEnabled(BOOL enabled);

// 输出日志
void logMessage(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
