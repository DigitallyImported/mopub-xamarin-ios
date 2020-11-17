//
//  MPMockRewardedVideoAdapter.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoAdapter.h"
#import "MPAdConfiguration.h"

@interface MPMockRewardedVideoAdapter : MPRewardedVideoAdapter

- (instancetype)initWithDelegate:(id<MPRewardedVideoAdapterDelegate>)delegate configuration:(MPAdConfiguration *)config;

@end
