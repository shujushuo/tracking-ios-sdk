// DataUploader.m

#import "DataUploader.h"
#import "EventStorage.h"
#import "Logger.h"

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

- (void)uploadAllStoredEventsWithCompletion:(void (^)(BOOL success))completion {
    NSArray<NSDictionary *> *events = [[EventStorage sharedInstance] retrieveAllEvents];
    
    if (events.count == 0) {
        logMessage(@"No events to upload.");
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    // 创建上传队列
    dispatch_group_t uploadGroup = dispatch_group_create();
    __block BOOL allSuccess = YES;
    NSMutableArray<NSNumber *> *successfullyUploadedEventIds = [NSMutableArray array];
    
    // 创建一个串行队列来确保线程安全地修改数组
    dispatch_queue_t serialQueue = dispatch_queue_create("com.example.uploadQueue", DISPATCH_QUEUE_SERIAL);
    
    for (NSDictionary *event in events) {
        NSNumber *eventId = event[@"id"];
        if (!eventId) {
            logMessage(@"Event does not have an 'id' key: %@", event);
            continue; // 跳过没有 'id' 的事件
        }
        
        // 创建一个没有 'id' 的事件副本用于上传
        NSMutableDictionary *eventToUpload = [event mutableCopy];
        [eventToUpload removeObjectForKey:@"id"];
        
        dispatch_group_enter(uploadGroup);
        [self uploadEvent:eventToUpload completion:^(BOOL success) {
            if (success) {
                // 线程安全地添加事件 id
                dispatch_async(serialQueue, ^{
                    [successfullyUploadedEventIds addObject:eventId];
                });
            } else {
                allSuccess = NO;
            }
            dispatch_group_leave(uploadGroup);
        }];
    }
    
    dispatch_group_notify(uploadGroup, dispatch_get_main_queue(), ^{
        // 等待所有事件 id 被安全地添加
        dispatch_sync(serialQueue, ^{
            if (successfullyUploadedEventIds.count > 0) {
                [[EventStorage sharedInstance] removeEventsWithIds:successfullyUploadedEventIds];
            }
        });
        if (completion) {
            completion(allSuccess);
        }
    });
}

- (void)uploadEvent:(NSDictionary *)event completion:(void (^)(BOOL success))completion {
    // 去除 URL 字符串的前后空格和换行
    NSString *trimmedServerURL = [self.serverURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 创建 NSURL 对象
    NSURL *url = [NSURL URLWithString:trimmedServerURL];
    
    // 检查 URL 是否有效
    if (!url) {
        logMessage(@"Invalid server URL: %@", trimmedServerURL);
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    logMessage(@"Making request to: %@", url);
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // 序列化事件字典为 JSON 数据
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:event options:0 error:&error];
    
    if (error) {
        logMessage(@"Error serializing event: %@", error.localizedDescription);
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    // 打印 JSON 字符串（可选）
    NSString *jsonString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    logMessage(@"serializing event: %@", jsonString);
    
    // 设置请求体
    request.HTTPBody = bodyData;
    
    // 创建数据任务
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            logMessage(@"Error uploading event: %@", error.localizedDescription);
            if (completion) {
                completion(NO);
            }
        } else {
            // 检查 HTTP 状态码
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                //真实成功，返回completion(YES)，删除本地缓存
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                logMessage(@"Server responded: %ld %@", (long)httpResponse.statusCode,responseString);
                if (completion) {
                    completion(YES);
                }
            }else if (httpResponse.statusCode >= 400 && httpResponse.statusCode < 500){
                // 没有成功，是因为本地数据有问题，返回completion(YES)，是为了能删除本地缓存，以免造成错误数据堆积
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                logMessage(@"Server responded: %ld %@", (long)httpResponse.statusCode,responseString);
                if (completion) {
                    completion(YES);
                }
            }
            else {
                //因为服务器端异常，返回completion(NO)，不会删除缓存
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                logMessage(@"Server responded: %ld %@", (long)httpResponse.statusCode,responseString);
                if (completion) {
                    completion(NO);
                }
            }
        }
    }];
    
    // 启动任务
    [dataTask resume];
}

@end
