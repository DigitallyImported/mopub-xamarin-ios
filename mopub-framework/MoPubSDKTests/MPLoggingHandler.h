//
//  MPLoggingHandler.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPBLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPLoggingHandler : NSObject <MPBLogger>
@property (nonatomic, copy, nullable) void(^didLogEventHandler)(NSString * _Nullable message);

+ (instancetype)handler:(void(^)(NSString * _Nullable message))didLogEventHandler;
@end

NS_ASSUME_NONNULL_END
