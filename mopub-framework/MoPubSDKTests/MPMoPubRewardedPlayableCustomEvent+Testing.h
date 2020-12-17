//
//  MPMoPubRewardedPlayableCustomEvent+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMoPubRewardedPlayableCustomEvent.h"
#import "MPMRAIDInterstitialViewController.h"
#import "MPCountdownTimerView.h"

@interface MPMoPubRewardedPlayableCustomEvent (Testing)
@property (nonatomic, readonly) BOOL isCountdownActive;
@property (nonatomic, strong) MPMRAIDInterstitialViewController *interstitial;
@property (nonatomic, strong) MPCountdownTimerView *timerView;

- (instancetype)initWithInterstitial:(MPMRAIDInterstitialViewController *)interstitial;

@end
