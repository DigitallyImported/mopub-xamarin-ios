//
//  MPRewardedVideoAdManager+Testing.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoAdManager+Testing.h"
#import "MPMockRewardedVideoAdapter.h"

@interface MPRewardedVideoAdManager() <MPRewardedVideoAdapterDelegate>
// Properties and methods from MPRewardedVideoAdManager redeclared here so we can access these private items.
@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, assign) BOOL ready;
@property (nonatomic, assign) BOOL playedAd;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation MPRewardedVideoAdManager (Testing)
@dynamic communicator;
@dynamic adapter;

- (void)loadWithConfiguration:(MPAdConfiguration *)config {
    self.adapter = [[MPMockRewardedVideoAdapter alloc] initWithDelegate:self configuration:config];
    self.configuration = config;
    self.ready = YES;
    self.playedAd = NO;
}

@end

#pragma clang diagnostic pop
