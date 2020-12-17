//
//  MPBannerCustomEventAdapter+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPBannerCustomEventAdapter.h"

@interface MPBannerCustomEventAdapter (Testing)

@property (nonatomic, strong) MPBannerCustomEvent *bannerCustomEvent;
@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;

- (void)loadAdWithConfiguration:(MPAdConfiguration *)configuration customEvent:(MPBannerCustomEvent *)customEvent;
- (void)setHasTrackedImpression:(BOOL)hasTrackedImpression;
- (void)adViewWillLogImpression:(UIView *)adView;

- (BOOL)shouldTrackImpressionOnDisplay;
- (void)startTimeoutTimer;

@end
