// NetworkMonitor.h

#import <Foundation/Foundation.h>

@interface NetworkMonitor : NSObject

+ (instancetype)sharedInstance;
- (void)startMonitoring;
- (void)stopMonitoring;

@end
