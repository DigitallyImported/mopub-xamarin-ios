//
//  MPMockRewardedVideoAdapter.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockRewardedVideoAdapter.h"
#import "MPAdConfiguration.h"
#import "NSString+MPAdditions.h"

@interface MPMockRewardedVideoAdapter()
@property (nonatomic, strong) MPAdConfiguration * configuration;
@property (nonatomic, strong) MPRewardedVideoCustomEvent * rewardedVideoCustomEvent;
@property (nonatomic, copy) NSString * customData;
@end

@implementation MPMockRewardedVideoAdapter
@dynamic configuration;
@dynamic rewardedVideoCustomEvent;
@dynamic customData;

- (instancetype)initWithDelegate:(id<MPRewardedVideoAdapterDelegate>)delegate configuration:(MPAdConfiguration *)config {
    if (self = [super initWithDelegate:delegate]) {
        self.configuration = config;

        if (config.customEventClass != nil) {
            self.rewardedVideoCustomEvent = [[config.customEventClass alloc] init];
        }
    }

    return self;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController customData:(NSString *)customData {
    // Only persist the custom data field if it's non-empty and there is a server-to-server
    // callback URL.
    if (customData.length > 0 && self.configuration.rewardedVideoCompletionUrl != nil) {
        self.customData = customData;
    }

    [self.delegate rewardedVideoWillAppearForAdapter:self];
    [self.delegate rewardedVideoDidAppearForAdapter:self];

    if (self.configuration.rewardedVideoCompletionUrl == nil) {
        [self.delegate rewardedVideoShouldRewardUserForAdapter:self reward:self.configuration.selectedReward];
    }
    else {
        [self rewardedVideoShouldRewardUserForCustomEvent:nil reward:self.configuration.selectedReward];
    }

    [self.delegate rewardedVideoWillDisappearForAdapter:self];
    [self.delegate rewardedVideoDidDisappearForAdapter:self];
}

@end
