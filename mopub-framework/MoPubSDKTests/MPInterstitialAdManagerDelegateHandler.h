//
//  MPInterstitialAdManagerDelegateHandler.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPInterstitialAdManager.h"
#import "MPInterstitialAdManagerDelegate.h"
#import "MPImpressionData.h"

typedef void(^MPInterstitialAdManagerDelegateHandlerBlock)(void);
typedef void(^MPInterstitialAdManagerDelegateHandlerImpressionBlock)(MPImpressionData *);
typedef void(^MPInterstitialAdManagerDelegateHandlerErrorBlock)(NSError *);

@interface MPInterstitialAdManagerDelegateHandler : NSObject <MPInterstitialAdManagerDelegate>

@property (nonatomic, copy) NSString * adUnitId;
@property (nonatomic, strong) MPInterstitialAdController * interstitialAdController;
@property (nonatomic, strong) CLLocation * location;
@property (nonatomic, weak) id interstitialDelegate;

@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock didLoadAd;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerErrorBlock didFailToLoadAd;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock willPresent;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock didPresent;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock willDismiss;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock didDismiss;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock didExpire;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock didTap;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerImpressionBlock didReceiveImpression;

@end
