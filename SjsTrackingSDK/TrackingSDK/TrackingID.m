//
//  TrackingID.m
//  Pods
//
//  Created by sylar on 2025/1/9.
//
#import "TrackingID.h"
#import <sys/sysctl.h>
#import <sys/time.h>
#import "DataUploader.h"
#import "MD5Util.h"
#import "CryptoHelper.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/mount.h>
#import <sys/stat.h>
#import <Security/Security.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import <sys/utsname.h>
#import "Logger.h"


@interface TrackingID ()


@end

@implementation TrackingID
NSString *unknwo_idfa = @"00000000-0000-0000-0000-000000000000";
static NSString *_caid = nil;

+ (instancetype)sharedInstance {
    static TrackingID *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TrackingID alloc] init];
    });
    return sharedInstance;
}
- (NSDictionary *)getDeviceInfo {
    
    NSDictionary *deviceInfo = @{
        @"bootTimeInSec":[self getBootTimeInSec],
        @"countryCode":[self getCountryCode],
        @"language":[self getLanguage],
        @"deviceName":[self getDeviceName],
        @"systemVersion":[self getSystemVersion],
        @"machine":[self getMachine],
        @"carrierInfo":[self getCarrierInfo],
        @"memory":[self getMemory],
        @"disk":[self getDisk],
        @"sysFileTime":[self getSysFileTime],
        @"model":[self getDeviceModel],
        @"timeZone":[self getTimeZone],
        @"deviceInitTime":@"1727760882",//[self getFileInitTime],
        @"mntId":[self getMntId],
    };
    
    
    
    return deviceInfo;
}
#pragma mark - 获取硬件信息

static time_t bootSecTime(void){
    struct timeval boottime;
    size_t len = sizeof(boottime);
    int mib[2] = { CTL_KERN, KERN_BOOTTIME };
    if( sysctl(mib, 2, &boottime, &len, NULL, 0) < 0 )
    {
        return 0;
    }
    return boottime.tv_sec;
    
}

- (NSString *)getBootTimeInSec {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [NSString stringWithFormat:@"%ld",bootSecTime()];
    });
    return value;
}

-(NSString *)getCountryCode
{
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLocale *locale = [NSLocale currentLocale];
        value = [locale objectForKey:NSLocaleCountryCode];
    });
    return value;
}

-(NSString *)getLanguage {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLocale *locale = [NSLocale currentLocale];
        if ([[NSLocale preferredLanguages] count] > 0) {
            value = [[NSLocale preferredLanguages]objectAtIndex:0];
        } else {
            value = [locale objectForKey:NSLocaleLanguageCode];
        }
    });
    return value;
}

-(NSString *)getDeviceName
{
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        
        if ([[[UIDevice currentDevice] name] length] == 0) {
            value = nil;
        }
        NSString *name =[[UIDevice currentDevice] name];
        logMessage(@"rawName: %@",name);
        //        NSString *lowercaseName = [rawName lowercaseString];
        value = [CAIDMD5Util md5HexDigest:name];
        
    });
    return value;
}



-(NSString* )getCarrierInfo {
#if TARGET_IPHONE_SIMULATOR
    return @"SIMULATOR";
#else
    static dispatch_queue_t _queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"com.carr.%@"
                                         , self] UTF8String], NULL);
    });
    __block NSString * carr = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(_queue, ^(){
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = nil;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 12.1) {
            if ([info respondsToSelector:@selector
                 (serviceSubscriberCellularProviders)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
                NSArray *carrierKeysArray =
                [info.serviceSubscriberCellularProviders
                    .allKeys sortedArrayUsingSelector:@selector(compare:)];
                carrier = info.serviceSubscriberCellularProviders
                [carrierKeysArray.firstObject];
                if (!carrier.mobileNetworkCode) {
                    carrier = info.serviceSubscriberCellularProviders
                    [carrierKeysArray.lastObject];
                }
#pragma clang diagnostic pop
            }
        }
        if(!carrier) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            carrier = info.subscriberCellularProvider;
#pragma clang diagnostic pop
        }
        if (carrier != nil) {
            NSString *networkCode = [carrier mobileNetworkCode];
            NSString *countryCode = [carrier mobileCountryCode];
            if (countryCode && [countryCode isEqualToString:@"460"] &&
                networkCode
                ) {
                if ([networkCode isEqualToString:@"00"] ||
                    [networkCode isEqualToString:@"02"] ||
                    [networkCode isEqualToString:@"07"] ||
                    [networkCode isEqualToString:@"08"]) {
                    carr= @"中国移动";
                }
                if ([networkCode isEqualToString:@"01"]
                    || [networkCode isEqualToString:@"06"]
                    || [networkCode isEqualToString:@"09"]) {
                    carr= @"中国联通";
                }
                if ([networkCode isEqualToString:@"03"]
                    || [networkCode isEqualToString:@"05"]
                    || [networkCode isEqualToString:@"11"]) {
                    carr= @"中国电信";
                }
                if ([networkCode isEqualToString:@"04"]) {
                    carr= @"中国卫通";
                }
                if ([networkCode isEqualToString:@"20"]) {
                    carr= @"中国铁通";
                }
            }else {
                carr = [carrier.carrierName copy];
            }
        }
        if (carr.length <= 0) {
            carr = @"unknown";
        }
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, 0.5* NSEC_PER_SEC);
    dispatch_semaphore_wait(semaphore, t);
    return [carr copy];
#endif
}

- (NSString *) getMemory
{
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [NSString stringWithFormat:@"%lld", [NSProcessInfo processInfo]
                 .physicalMemory];
    });
    return value;
}

-(NSString *)getDisk
{
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        int64_t space = -1;
        NSError *error = nil;
        NSDictionary *attrs = [[NSFileManager defaultManager]
                               attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
        if (!error) {
            space = [[attrs objectForKey:NSFileSystemSize] longLongValue];
        }
        if(space < 0) {
            space = -1;
        }
        value = [NSString stringWithFormat:@"%lld",space];
    });
    return value;
}
-(NSString *)getSysFileTime {
    
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //L3Zhci9tb2JpbGUvTGlicmFyeS9Vc2VyQ29uZmlndXJhdGlvblByb2ZpbGVzL1B1YmxpY0luZm8vTUNNZXRhLnBsaXN0
        NSString *information = @"L3Zhci9tb2JpbGUvTGlicmFyeS9Vc2VyQ29uZmlndXJhdGlvblByb2ZpbGVzL1B1YmxpY0luZm8vTUNNZXRhLnBsaXN0";
        NSData *data=[[NSData alloc]initWithBase64EncodedString:information
                                                        options:0];
        NSString *dataString = [[NSString alloc]initWithData:data
                                                    encoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:dataString error:&error];
        if (fileAttributes) {
            id singleAttibute = [fileAttributes objectForKey:NSFileCreationDate];
            if ([singleAttibute isKindOfClass:[NSDate class]]) {
                NSDate *dataDate = singleAttibute;
                value = [NSString stringWithFormat:@"%f",[dataDate timeIntervalSince1970]];
            }
        }
        
    });
    return value;}


static NSString *getSystemHardwareByName(const char *typeSpecifier) {
    static NSString *value = nil;
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    value = [NSString stringWithUTF8String:answer];
    free(answer);
    return value;
}

static const char *SIDFAModel = "hw.model";
-(NSString *_Nonnull)getDeviceModel
{
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *model = getSystemHardwareByName(SIDFAModel);
        value = model == nil ? @"" : model;
    });
    return value;
}


static const char *SIDFAMachine = "hw.machine";

-(NSString *)getMachine
{
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *machine = getSystemHardwareByName(SIDFAMachine);
        value = machine == nil ? @"" : machine;
    });
    return value;
}

- (NSString *) getTimeZone
{
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSInteger offset = [NSTimeZone systemTimeZone].secondsFromGMT;
        value = [NSString stringWithFormat:@"%ld",(long)offset];
    });
    return value;
}

-(NSString *) getMntId
{
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct statfs buf;
        statfs("/", &buf);
        char* prefix = "com.apple.os.update-";
        if(strstr(buf.f_mntfromname, prefix)) {
            value = [NSString stringWithFormat:@"%s", buf.f_mntfromname+strlen(prefix)];
        }
        value= @"";
    });
    return value;
    
}

-(NSString *)getFileInitTime
{
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct stat info;
        int result = stat("/var/mobile", &info);
        if (result != 0) {
            value = @"";
        }
        struct timespec time = info.st_birthtimespec;
        value = [NSString stringWithFormat:@"%ld.%09ld",time.tv_sec,
                 time.tv_nsec];
    });
    return value;
}

- (NSString *)getSystemVersion {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[UIDevice currentDevice] systemVersion];
    });
    return value;
}



#pragma mark - 获取硬件信息


#pragma mark - 获取设备基础信息


// 获取 CAID
- (NSString *)getCAID {
    return _caid;  // 返回已经设置的值
}

// 获取 CAID

- (void)setCAID:(NSString * _Nonnull)caid {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _caid = [caid copy];  // 保证只设置一次
    });
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:caid forKey:@"CAID"];
    [defaults synchronize];
    
}

// 获取设备型号
- (NSString *)getModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    });
    return value;
}


// 获取IDFA
- (NSString *)getIDFA {
    static NSString *value = nil;
    if (!value) {
        // 如果还没有缓存的 IDFA，则尝试获取
        // 在第一次调用时，检查权限并尝试获取 IDFA
        if (@available(iOS 14, *)) {
            ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                // 如果授权，获取 IDFA
                value = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
                logMessage(@"IDFA: %@", value);  // 打印 IDFA
            } else {
                logMessage(@"IDFA权限未授权");
            }
        } else {
            // 对于早期版本的 iOS，直接获取 IDFA
            value = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            logMessage(@"IDFA: %@", value);  // 打印 IDFA
        }
    }
    return value;
}

// 获取IDFV
- (NSString *)getIDFV {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[UIDevice currentDevice].identifierForVendor UUIDString] ?: unknwo_idfa;
    });
    return value;
}

// 获取IDFV
- (NSString *)getBrand {
    return @"apple";
}


- (NSString *)getInstallID {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [self getFromKeychainForKey:@"installID"];
        if (!value) {
            NSString *deviceID = [self getIDFA];
            if (deviceID.length == 0 || [deviceID  isEqual: unknwo_idfa]) {
                // 如果 IDFA 为空，则使用 CAID
                deviceID = [self getCAID];
                if (deviceID.length == 0 || [deviceID isEqual: @"unknown"]) {
                    // 如果 CAID 为空，则使用 IDFV
                    deviceID = [self getIDFV];
                }
            }
            NSString *timestamp = [NSString stringWithFormat:@"%lld", (long long)([[NSDate date] timeIntervalSince1970] * 1000)];
            value = [NSString stringWithFormat:@"%@_%@", timestamp, deviceID];
            [self saveToKeychain:value forKey:@"installID"];
        }
        
    });
    return value;
}


- (NSString *)getPkgName {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[NSBundle mainBundle] bundleIdentifier];
    });
    return value;
}

- (NSString *)getPkgVersion {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    });
    return value;
}
#pragma mark - 获取设备基础信息


#pragma mark - 钥匙串读写

// 从钥匙链读取数据
- (NSString *)getFromKeychainForKey:(NSString *)key {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrAccount] = key;
    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    
    CFDataRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    
    if (status == errSecSuccess && result != NULL) {
        NSData *data = (__bridge_transfer NSData *)result;
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return dataString;
    }
    
    return nil;
}

// 存储数据到钥匙链
- (void)saveToKeychain:(NSString *)data forKey:(NSString *)key {
    logMessage(@"saveToKeychain");
    
    NSData *dataToStore = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrAccount] = key;
    query[(__bridge id)kSecValueData] = dataToStore;
    
    // 删除现有的钥匙链数据
    SecItemDelete((__bridge CFDictionaryRef)query);
    
    // 添加新的钥匙链数据
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    if (status != errSecSuccess) {
        logMessage(@"Failed to save data to keychain: %d", (int)status);
    }
}

@end
