// DataUploader.h

#import <Foundation/Foundation.h>

@interface DataUploader : NSObject

+ (instancetype)sharedInstance;

- (void)setServerURL:(NSString *)url;
- (void)uploadAllStoredEventsWithCompletion:(void (^)(BOOL success))completion;

@end
