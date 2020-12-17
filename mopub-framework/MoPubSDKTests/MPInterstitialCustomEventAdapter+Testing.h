//
//  MPInterstitialCustomEventAdapter+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInterstitialCustomEventAdapter.h"

@interface MPInterstitialCustomEventAdapter (Testing)

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent didLoadAd:(id)ad;
- (void)startTimeoutTimer;

@property (nonatomic, strong) MPAdConfiguration * configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, strong) MPInterstitialCustomEvent * interstitialCustomEvent;

@end
