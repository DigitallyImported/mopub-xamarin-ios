//
//  MPSampleAppInstanceProvider.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPSampleAppInstanceProvider.h"
#import "MPAdView.h"
#import "MPInterstitialAdController.h"

static MPSampleAppInstanceProvider *sharedProvider = nil;

@implementation MPSampleAppInstanceProvider

+ (MPSampleAppInstanceProvider *)sharedProvider
{
    if (!sharedProvider) {
        sharedProvider = [[MPSampleAppInstanceProvider alloc] init];
    }
    return sharedProvider;
}

- (MPAdView *)buildMPAdViewWithAdUnitID:(NSString *)ID size:(CGSize)size
{
    return [[MPAdView alloc] initWithAdUnitId:ID size:size];
}

- (MPInterstitialAdController *)buildMPInterstitialAdControllerWithAdUnitID:(NSString *)ID
{
    return [MPInterstitialAdController interstitialAdControllerForAdUnitId:ID];
}

@end
