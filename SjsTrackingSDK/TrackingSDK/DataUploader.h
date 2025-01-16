// DataUploader.h

#import <Foundation/Foundation.h>

@interface DataUploader : NSObject

+ (instancetype)sharedInstance;

- (void)setBaseURL:(NSString *)url;
- (void)setKey:(NSString *)key;
- (void)setIv:(NSString *)iv;
- (void)uploadAllStoredEventsWithCompletion:(void (^)(BOOL success))completion;
- (void)testServerAlive:(void (^)(BOOL success))completion;
- (void)requestCaidWithCompletion:(NSDictionary *)deviceInfo completion:(void (^)(BOOL success, NSString *responseString))completion ;
@end
