//
//  MPSampleAppInstanceProvider.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

@class MPAdView, MPInterstitialAdController;

@interface MPSampleAppInstanceProvider : NSObject

+ (MPSampleAppInstanceProvider *)sharedProvider;
- (MPAdView *)buildMPAdViewWithAdUnitID:(NSString *)ID size:(CGSize)size;
- (MPInterstitialAdController *)buildMPInterstitialAdControllerWithAdUnitID:(NSString *)ID;

@end
