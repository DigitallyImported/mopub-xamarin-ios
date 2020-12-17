//
//  MPRewardedVideoAdManager+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoAdManager.h"
#import "MPAdConfiguration.h"
#import "MPRewardedVideoAdapter.h"
#import "MPAdServerCommunicator.h"
#import "MPRewardedVideoAdapter+Testing.h"

@interface MPRewardedVideoAdManager (Testing) <MPAdServerCommunicatorDelegate>
@property (nonatomic, strong) MPAdServerCommunicator * communicator;
@property (nonatomic, strong) MPRewardedVideoAdapter * adapter;

/**
 * Pretends to load the class with a rewarded ad and sets the configuration.
 * @param config Testing configuration to set.
 */
- (void)loadWithConfiguration:(MPAdConfiguration *)config;

@end
