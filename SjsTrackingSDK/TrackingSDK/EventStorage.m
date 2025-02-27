// EventStorage.m

#import "EventStorage.h"
#import "FMDB/FMDB.h"
#import <sys/utsname.h>
#import "Logger.h"

@interface EventStorage ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation EventStorage

+ (instancetype)sharedInstance {
    static EventStorage *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EventStorage alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 设置数据库路径
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"events.sqlite"];
        
        // 初始化数据库队列
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        
        // 创建事件表
        [self createEventsTable];
    }
    return self;
}

- (void)createEventsTable {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *createTableQuery = @"CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY AUTOINCREMENT, event TEXT);";
        BOOL success = [db executeUpdate:createTableQuery];
        if (!success) {
            logMessage(@"Failed to create events table: %@", [db lastErrorMessage]);
        }
    }];
}

- (void)saveEvent:(NSDictionary *)event {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:event options:0 error:&error];
    NSString *eventString = @"";
    if (!error && jsonData) {
        eventString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    } else {
        logMessage(@"Error serializing event: %@", error.localizedDescription);
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *insertQuery = @"INSERT INTO events (event) VALUES (?);";
        BOOL success = [db executeUpdate:insertQuery, eventString];
        if (!success) {
            logMessage(@"Failed to insert event: %@", [db lastErrorMessage]);
        }
    }];
}

- (NSArray<NSDictionary *> *)retrieveAllEvents {
    NSMutableArray<NSDictionary *> *eventsArray = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *selectQuery = @"SELECT * FROM events ORDER BY id ASC;";
        FMResultSet *results = [db executeQuery:selectQuery];
        
        while ([results next]) {
            NSNumber *eventID = @([results intForColumn:@"id"]);
            NSString *eventString = [results stringForColumn:@"event"];
            
            if (eventString && eventString.length > 0) {
                NSData *data = [eventString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSMutableDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if (!error && [eventDict isKindOfClass:[NSDictionary class]]) {
                    // 添加 eventID 到事件字典
                    eventDict[@"id"] = eventID;
                    [eventsArray addObject:eventDict];
                } else {
                    logMessage(@"Error parsing event JSON: %@", error.localizedDescription);
                }
            }
        }
        
        [results close];
    }];
    
    return [eventsArray copy];
}

- (void)removeEventsWithIds:(NSArray<NSNumber *> *)eventIds {
    if (eventIds.count == 0) {
        return;
    }
    
    // 创建逗号分隔的id字符串
    NSMutableArray<NSString *> *idStrings = [NSMutableArray array];
    for (NSNumber *idNumber in eventIds) {
        [idStrings addObject:[idNumber stringValue]];
    }
    NSString *idsString = [idStrings componentsJoinedByString:@","];
    
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM events WHERE id IN (%@);", idsString];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:deleteQuery];
        if (!success) {
            logMessage(@"Failed to delete events with ids %@: %@", idsString, [db lastErrorMessage]);
        } else {
            logMessage(@"Successfully deleted events with ids: %@", idsString);
        }
    }];
}
@end
