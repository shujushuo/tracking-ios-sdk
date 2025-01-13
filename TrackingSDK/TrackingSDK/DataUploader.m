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
    dispatch_queue_t serialQueue = dispatch_queue_create("com.shujushuo.tracking.uploadQueue", DISPATCH_QUEUE_SERIAL);
    
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
    NSURL *url = [NSURL URLWithString:trimmedServerURL];
    
    // 检查 URL 是否有效
    if (!url) {
        logMessage(@"Invalid server URL: %@", trimmedServerURL);
        if (completion) completion(NO);
        return;
    }
    
    logMessage(@"Making request to: %@", url);
    
    // 序列化事件字典为 JSON 数据
    NSError *serializationError = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:event options:0 error:&serializationError];
    if (serializationError) {
        logMessage(@"Error serializing event: %@", serializationError.localizedDescription);
        if (completion) completion(NO);
        return;
    }
    
    // 打印 JSON 字符串（可选）
    NSString *jsonString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    logMessage(@"Serializing event: %@", jsonString);
    
    // 创建请求并设置 HTTP 方法及头
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = bodyData;
    
    // 创建数据任务
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *taskError) {
        if (taskError) {
            logMessage(@"Error uploading event: %@", taskError.localizedDescription);
            if (completion) completion(NO);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSString *responseString = (data && data.length > 0) ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";
            logMessage(@"Server responded: %ld %@", (long)httpResponse.statusCode, responseString);
            
            // 状态码在 200-299 或 400-499 范围内视为成功
            BOOL success = ((httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) ||
                            (httpResponse.statusCode >= 400 && httpResponse.statusCode < 500));
            if (completion) completion(success);
        }
    }];
    
    // 启动任务
    [dataTask resume];
}


@end
