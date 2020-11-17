//
//  MPMRectBannerAdDetailViewController.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMRectBannerAdDetailViewController.h"
#import "MPSampleAppInstanceProvider.h"
#import "MPAdInfo.h"
#import "MPConstants.h"

@interface MPBannerAdDetailViewController ()

@property (nonatomic, strong) MPAdInfo *info;
@property (nonatomic, strong) MPAdView *adView;
@property (nonatomic, assign) BOOL didLoadAd;

@end

@interface MPMRectBannerAdDetailViewController ()

@end

@implementation MPMRectBannerAdDetailViewController

// override
- (void)configureAd
{
    CGFloat sideBuffer = (self.view.bounds.size.width - MOPUB_MEDIUM_RECT_SIZE.width) / 2;
    self.adViewContainer.frame = CGRectMake(sideBuffer, self.adViewContainer.frame.origin.y, MOPUB_MEDIUM_RECT_SIZE.width, MOPUB_MEDIUM_RECT_SIZE.height);

    self.adView = [[MPSampleAppInstanceProvider sharedProvider] buildMPAdViewWithAdUnitID:self.info.ID
                                                                                     size:MOPUB_MEDIUM_RECT_SIZE];
    self.adView.delegate = self;
    self.adView.accessibilityLabel = @"mrect_banner";
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.adViewContainer addSubview:self.adView];
}

@end
