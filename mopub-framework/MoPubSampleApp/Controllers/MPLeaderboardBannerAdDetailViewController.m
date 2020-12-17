//
//  MPLeaderboardBannerAdDetailViewController.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPLeaderboardBannerAdDetailViewController.h"
#import "MPAdInfo.h"
#import "MPSampleAppInstanceProvider.h"
#import "MPConstants.h"

@interface MPBannerAdDetailViewController ()

@property (nonatomic, strong) MPAdInfo *info;
@property (nonatomic, strong) MPAdView *adView;
@property (nonatomic, assign) BOOL didLoadAd;

@end

@implementation MPLeaderboardBannerAdDetailViewController

// override
- (void)configureAd
{
    // since our xib is targeted for the iPhone, ie, 320xH, we need to use UIScreen's bounds to determine proper centering.
    CGRect screenBounds = [UIScreen mainScreen].bounds;

    CGFloat sideBuffer = (screenBounds.size.width - MOPUB_LEADERBOARD_SIZE.width) / 2;

    // again, our xib is targeted for the iPhone, so we can't use MOPUB_LEADERBOARD_SIZE.width as the width here. Subtract
    // left and right margins to center the container in the 320-width coordinate space
    self.adViewContainer.frame = CGRectMake(sideBuffer, self.adViewContainer.frame.origin.y, self.view.bounds.size.width - sideBuffer * 2, MOPUB_LEADERBOARD_SIZE.height);

    self.adView = [[MPSampleAppInstanceProvider sharedProvider] buildMPAdViewWithAdUnitID:self.info.ID
                                                                                     size:MOPUB_LEADERBOARD_SIZE];
    self.adView.delegate = self;
    self.adView.accessibilityLabel = @"leaderboard_banner";
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.adViewContainer addSubview:self.adView];
}

@end
