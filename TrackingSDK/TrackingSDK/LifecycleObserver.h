//
//  TrackingLifecycleObserver.h
//  Pods
//
//  Created by sylar on 2025/1/12.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LifecycleObserver : NSObject

+ (instancetype)sharedObserver;

- (void)startObserving;  // 开始监听生命周期通知
- (void)stopObserving;   // 停止监听生命周期通知（如果需要）

@end

NS_ASSUME_NONNULL_END
