//
//  MPRateLimitConfiguration+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRateLimitConfiguration.h"
#import "MPRealTimeTimer.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPRateLimitConfiguration (Testing)

@property (nonatomic, strong, nullable) MPRealTimeTimer * timer;

@end

NS_ASSUME_NONNULL_END
