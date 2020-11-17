//
//  MPMockChartboostRewardedVideoCustomEvent.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockChartboostRewardedVideoCustomEvent.h"
#import "MPMockChartboostAdapterConfiguration.h"

@implementation MPMockChartboostRewardedVideoCustomEvent

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    [MPMockChartboostAdapterConfiguration setCachedInitializationParameters:info];
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

@end
