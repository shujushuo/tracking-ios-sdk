//
//  DataUploader.h
//  TrackingSDK
//
//  Created by sylar on 2025/1/4.
//


// DataUploader.h

#import <Foundation/Foundation.h>

@interface DataUploader : NSObject

+ (instancetype)sharedInstance;
- (void)setServerURL:(NSString *)url;
- (void)uploadEvent:(NSDictionary *)event completion:(void (^)(BOOL success))completion;

@end
