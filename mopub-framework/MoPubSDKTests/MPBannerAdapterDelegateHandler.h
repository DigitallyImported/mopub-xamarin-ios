//
//  MPBannerAdapterDelegateHandler.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPBaseBannerAdapter.h"

typedef void(^MPBannerAdapterDelegateHandlerBlock)(void);
typedef void(^MPBannerAdapterDelegateHandlerFailureBlock)(NSError * error);

@interface MPBannerAdapterDelegateHandler : NSObject <MPBannerAdapterDelegate>

@property (nonatomic, strong) MPAdView * banner;
@property (nonatomic, weak) id<MPAdViewDelegate> bannerDelegate;
@property (nonatomic, strong) UIViewController * viewControllerForPresentingModalView;
@property (nonatomic, assign) MPNativeAdOrientation allowedNativeAdsOrientation;
@property (nonatomic, strong) CLLocation * location;

@property (nonatomic, copy) MPBannerAdapterDelegateHandlerBlock didLoadAd;
@property (nonatomic, copy) MPBannerAdapterDelegateHandlerFailureBlock didFailToLoadAd;
@property (nonatomic, copy) MPBannerAdapterDelegateHandlerBlock willBeginUserAction;
@property (nonatomic, copy) MPBannerAdapterDelegateHandlerBlock didFinishUserAction;
@property (nonatomic, copy) MPBannerAdapterDelegateHandlerBlock willLeaveApplication;
@property (nonatomic, copy) MPBannerAdapterDelegateHandlerBlock didTrackImpression;

@property (nonatomic, copy) MPBannerAdapterDelegateHandlerBlock willExpand;
@property (nonatomic, copy) MPBannerAdapterDelegateHandlerBlock didCollapse;

@end
