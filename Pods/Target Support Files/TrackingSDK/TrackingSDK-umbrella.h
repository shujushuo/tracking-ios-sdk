#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "DataUploader.h"
#import "EventStorage.h"
#import "MD5Util.h"
#import "NetworkMonitor.h"
#import "TrackingID.h"
#import "TrackingSDK.h"

FOUNDATION_EXPORT double TrackingSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char TrackingSDKVersionString[];

