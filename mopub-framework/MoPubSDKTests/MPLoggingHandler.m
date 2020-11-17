//
//  MPLoggingHandler.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPLoggingHandler.h"
#import "MPLogging.h"

@implementation MPLoggingHandler

+ (instancetype)handler:(void(^)(NSString * _Nullable message))didLogEventHandler {
    MPLoggingHandler * handler = MPLoggingHandler.new;
    handler.didLogEventHandler = didLogEventHandler;
    return handler;
}

#pragma mark - MPBLogger

- (MPBLogLevel)logLevel {
    return MPBLogLevelDebug;
}

- (void)logMessage:(NSString * _Nullable)message {
    if (self.didLogEventHandler != nil) {
        self.didLogEventHandler(message);
    }
}

@end
