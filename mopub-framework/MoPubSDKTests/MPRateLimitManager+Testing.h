//
//  MPRateLimitManager+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRateLimitManager.h"
#import "MPRateLimitConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPRateLimitManager (Testing)

@property (nonatomic, copy) NSMutableDictionary <NSString *, MPRateLimitConfiguration *> * configurationDictionary;

@end

NS_ASSUME_NONNULL_END
