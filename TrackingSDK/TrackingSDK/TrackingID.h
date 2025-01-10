//
//  TrackingID.h
//  Pods
//
//  Created by sylar on 2025/1/9.
//

#import <Foundation/Foundation.h>


@interface TrackingID : NSObject

+ (instancetype _Nonnull )sharedInstance;


- (NSDictionary *_Nonnull)getDeviceInfo;

// 获取设备型号
- (NSString *_Nonnull)getDeviceModel;

// 获取IDFV
- (NSString *_Nonnull)getTrackingID;


// 获取设备型号
- (NSString *_Nonnull)getModel;


// 获取IDFA
- (NSString *_Nonnull)getIDFA;

// 获取IDFV
- (NSString *_Nonnull)getIDFV;


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



@end

