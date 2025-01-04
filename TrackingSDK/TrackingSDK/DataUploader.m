// DataUploader.m

#import "DataUploader.h"

@interface DataUploader()

@property (nonatomic, strong) NSString *serverURL;

@end

@implementation DataUploader

+ (instancetype)sharedInstance {
    static DataUploader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataUploader alloc] init];
    });
    return sharedInstance;
}

- (void)setServerURL:(NSString *)url {
    self.serverURL = url;
}

- (void)uploadEvent:(NSDictionary *)event completion:(void (^)(BOOL success))completion {
    NSURL *url = [NSURL URLWithString:self.serverURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = @{ @"Content-Type" : @"application/json" };
    
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:event options:0 error:&error];
    
    if (error) {
        completion(NO);
        return;
    }
    
    request.HTTPBody = bodyData;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(NO);
        } else {
            completion(YES);
        }
    }];
    
    [dataTask resume];
}

@end
