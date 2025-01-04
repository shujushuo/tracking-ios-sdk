// DataUploader.m

#import "DataUploader.h"
#import "EventStorage.h"

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

// 不手动实现 setServerURL:，让编译器自动生成 setter 和 getter

- (void)uploadAllStoredEventsWithCompletion:(void (^)(BOOL success))completion {
    NSArray<NSDictionary *> *events = [[EventStorage sharedInstance] retrieveAllEvents];
    
    if (events.count == 0) {
        NSLog(@"No events to upload.");
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    // 创建上传队列
    dispatch_group_t uploadGroup = dispatch_group_create();
    __block BOOL allSuccess = YES;
    NSMutableArray *successfullyUploadedEvents = [NSMutableArray array];
    
    for (NSDictionary *event in events) {
        dispatch_group_enter(uploadGroup);
        [self uploadEvent:event completion:^(BOOL success) {
            if (success) {
                [successfullyUploadedEvents addObject:event];
            } else {
                allSuccess = NO;
            }
            dispatch_group_leave(uploadGroup);
        }];
    }
    
    dispatch_group_notify(uploadGroup, dispatch_get_main_queue(), ^{
        if (successfullyUploadedEvents.count > 0) {
            [[EventStorage sharedInstance] removeEvents:successfullyUploadedEvents];
        }
        if (completion) {
            completion(allSuccess);
        }
    });
}

- (void)uploadEvent:(NSDictionary *)event completion:(void (^)(BOOL success))completion {
    if (!self.serverURL) {
        NSLog(@"Server URL not set.");
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:self.serverURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:event options:0 error:&error];
    
    if (error) {
        NSLog(@"Error serializing event: %@", error.localizedDescription);
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    request.HTTPBody = bodyData;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error uploading event: %@", error.localizedDescription);
            if (completion) {
                completion(NO);
            }
        } else {
            // 可根据服务器响应进一步处理
            NSLog(@"Event uploaded successfully.");
            if (completion) {
                completion(YES);
            }
        }
    }];
    
    [dataTask resume];
}

@end
