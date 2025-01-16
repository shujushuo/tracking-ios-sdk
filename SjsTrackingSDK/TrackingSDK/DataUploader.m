// DataUploader.m

#import "DataUploader.h"
#import "CryptoHelper.h"
#import "EventStorage.h"
#import "Logger.h"

@interface DataUploader()

@property (nonatomic, strong) NSString *baseURL;

@property (nonatomic, strong) NSString *key ;  // AES 密钥
@property (nonatomic, strong) NSString *iv ;  // AES 密钥


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
    NSString *trimmedServerURL = [self.baseURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *finalURLString;
    if ([trimmedServerURL hasSuffix:@"/"]) {
        finalURLString = [trimmedServerURL stringByAppendingString:@"up"];
    } else {
        finalURLString = [trimmedServerURL stringByAppendingString:@"/up"];
    }
    
    NSURL *url = [NSURL URLWithString:finalURLString];
    
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

- (void)requestCaidWithCompletion:(NSDictionary *)deviceInfo completion:(void (^)(BOOL success, NSString *jsonResponse))completion {
    // 这里的请求逻辑处理和你原来的方法一致
    NSString *finalURLString = @"";
    NSString *trimmedServerURL = [self.baseURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedServerURL hasSuffix:@"/"]) {
        finalURLString = [trimmedServerURL stringByAppendingString:@"caid"];
    } else {
        finalURLString = [trimmedServerURL stringByAppendingString:@"/caid"];
    }
    NSURL *url = [NSURL URLWithString:finalURLString];
    if (!url) {
        logMessage(@"Invalid server URL: %@", finalURLString);
        if (completion) completion(NO, nil);
        return;
    }
    
    // 直接使用传入的 deviceInfo 作为请求的 bodyData
    logMessage(@"Making request to: %@", url);

    NSError *serializationError = nil;
    NSData *encrypted_device_info = [NSJSONSerialization dataWithJSONObject:deviceInfo options:0 error:&serializationError];
    if (serializationError) {
        logMessage(@"Error serializing deviceInfo: %@", serializationError.localizedDescription);
        if (completion) completion(NO, nil);
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:encrypted_device_info encoding:NSUTF8StringEncoding];
    logMessage(@"jsonString: %@",jsonString);
    
    
    NSString *encryptedData = [CryptoHelper AES128EncryptData:encrypted_device_info withKey:[self key] iv:[self iv]];
    logMessage(@"jsonString base64 : %@",encryptedData);
    
    NSDictionary *requestBody = @{
        @"encrypted_device_info":encryptedData,
        @"pkg_name": @"xxxx",
        @"sdk_version": @"xxxx",
    };
    logMessage(@"requestBody: %@",requestBody);
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&serializationError];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = bodyData;
    
    // 发起请求
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *taskError) {
        if (taskError) {
            logMessage(@"Error uploading device info: %@", taskError.localizedDescription);
            if (completion) completion(NO, nil);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSString *responseString = (data && data.length > 0) ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";
            logMessage(@"Server responded: %ld %@", (long)httpResponse.statusCode, responseString);
            
            // 判断状态码，200-299 范围内视为成功
            BOOL success = (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300);
            if (success) {
                // 成功时解析返回的数据并解密 caid
                NSError *jsonError = nil;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError) {
                    logMessage(@"Error parsing JSON response: %@", jsonError.localizedDescription);
                    if (completion) completion(NO, nil);
                } else {
                    NSString *caidBase64 = jsonResponse[@"data"];
                    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:caidBase64 options:0];
                    NSString *decryptedData = [CryptoHelper AES128DecryptData:cipherData withKey:[self key] iv:[self iv]];
                    if (completion) completion(success, decryptedData);
                }
            } else {
                if (completion) completion(NO, nil);
            }
        }
    }];
    
    // 启动任务
    [dataTask resume];
}

- (void)testServerAlive:(void (^__strong)(BOOL))completion {
    NSURL *url = [NSURL URLWithString:[self baseURL]];
    
    // 确保 URL 有效
    if (url == nil) {
        logMessage(@"无效的 URL");
        completion(NO);
        return;
    }
    logMessage(@"Making request to: %@", url);

    // 创建 NSURLRequest 对象，并设置超时
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:15.0];  // 设置请求超时为15秒
    
    // 使用 NSURLSession 发送 GET 请求
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 检查是否有错误
        if (error) {
            logMessage(@"请求出错: %@", error.localizedDescription);
            completion(NO);
            return;
        }
        
        // 确保响应是 HTTPURLResponse 类型
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (httpResponse.statusCode == 200) {
                // 状态码为 200，表示请求成功
                logMessage(@"服务器返回 200 OK");
                completion(YES);
            } else {
                // 非 200 状态码
                logMessage(@"服务器返回非 200 状态码: %ld", (long)httpResponse.statusCode);
                completion(NO);
            }
        } else {
            // 响应类型错误
            NSLog(@"响应类型错误");
            completion(NO);
        }
    }];
    
    // 启动请求
    [dataTask resume];
}

@end
