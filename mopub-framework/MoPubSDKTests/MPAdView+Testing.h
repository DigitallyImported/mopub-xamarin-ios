//
//  MPAdView+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdView.h"
#import "MPBannerAdManager.h"

@interface MPAdView (Testing)
@property (nonatomic, strong) MPBannerAdManager *adManager;
- (void)impressionDidFireWithImpressionData:(MPImpressionData *)impressionData;
@end
