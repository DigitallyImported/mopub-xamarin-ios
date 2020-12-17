//
//  MPBannerAdManagerDelegateHandler.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPBannerAdManager.h"
#import "MPBannerAdManagerDelegate.h"
#import "MPImpressionData.h"

typedef void(^MPBannerAdManagerDelegateHandlerBlock)(void);
typedef void(^MPBannerAdManagerDelegateHandlerImpressionBlock)(MPImpressionData * impressionData);
typedef void(^MPBannerAdManagerDelegateHandlerErrorBlock)(NSError * error);

@interface MPBannerAdManagerDelegateHandler : NSObject <MPBannerAdManagerDelegate>

@property (nonatomic, copy) NSString * adUnitId;
@property (nonatomic, assign) MPNativeAdOrientation allowedNativeAdsOrientation;
@property (nonatomic, strong) MPAdView * banner;
@property (nonatomic, weak) id<MPAdViewDelegate> bannerDelegate;
@property (nonatomic, assign) CGSize containerSize;
@property (nonatomic, copy) NSString * keywords;
@property (nonatomic, copy) NSString * userDataKeywords;
@property (nonatomic, strong) CLLocation * location;
@property (nonatomic, strong) UIViewController * viewControllerForPresentingModalView;

@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerBlock didLoadAd;
@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerErrorBlock didFailToLoadAd;
@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerBlock willBeginUserAction;
@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerBlock didEndUserAction;
@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerBlock willLeaveApplication;
@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerImpressionBlock impressionDidFire;

@end
