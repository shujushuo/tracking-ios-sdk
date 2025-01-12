//
//  Logger.m
//  Pods
//
//  Created by sylar on 2025/1/12.
//

#import "Logger.h"

static BOOL loggingEnabled = NO;

void setLoggingEnabled(BOOL enabled) {
    loggingEnabled = enabled;
}


void logMessage(NSString *format, ...) {
    if (!loggingEnabled) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"[TrackingSDK] %@", message);
}
