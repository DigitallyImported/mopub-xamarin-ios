//
//  MPInterstitialAdController+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInterstitialAdController.h"
#import "MPInterstitialAdManager.h"

@interface MPInterstitialAdController (Testing)
@property (nonatomic, strong) MPInterstitialAdManager * manager;
- (void)interstitialAdManager:(MPInterstitialAdManager *)manager didReceiveImpressionEventWithImpressionData:(MPImpressionData *)impressionData;
@end
