// DataUploader.h

#import <Foundation/Foundation.h>

@interface DataUploader : NSObject

+ (instancetype)sharedInstance;

- (void)setBaseURL:(NSString *)url;
- (void)uploadAllStoredEventsWithCompletion:(void (^)(BOOL success))completion;

@end
