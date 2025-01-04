// EventStorage.h

#import <Foundation/Foundation.h>

@interface EventStorage : NSObject

+ (instancetype)sharedInstance;

- (void)saveEvent:(NSDictionary *)event;
- (NSArray<NSDictionary *> *)retrieveAllEvents;
- (void)removeEvents:(NSArray<NSDictionary *> *)events;

@end
