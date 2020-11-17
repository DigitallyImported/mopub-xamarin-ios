//
//  MPInterstitialAdapterDelegateHandler.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPBaseInterstitialAdapter.h"

typedef void(^MPInterstitialAdapterDelegateHandlerBlock)(MPBaseInterstitialAdapter *);
typedef void(^MPInterstitialAdapterDelegateHandlerErrorBlock)(MPBaseInterstitialAdapter *, NSError *);

@interface MPInterstitialAdapterDelegateHandler : NSObject <MPInterstitialAdapterDelegate>

@property (nonatomic, strong) MPInterstitialAdController *interstitialAdController;
@property (nonatomic, strong) id interstitialDelegate;
@property (nonatomic, copy) CLLocation *location;

@property (nonatomic, copy) MPInterstitialAdapterDelegateHandlerBlock didFinishLoadingAd;
@property (nonatomic, copy) MPInterstitialAdapterDelegateHandlerErrorBlock didFailToLoadAd;
@property (nonatomic, copy) MPInterstitialAdapterDelegateHandlerBlock willAppear;
@property (nonatomic, copy) MPInterstitialAdapterDelegateHandlerBlock didAppear;
@property (nonatomic, copy) MPInterstitialAdapterDelegateHandlerBlock willDisppear;
@property (nonatomic, copy) MPInterstitialAdapterDelegateHandlerBlock didDisppear;
@property (nonatomic, copy) MPInterstitialAdapterDelegateHandlerBlock didExpire;
@property (nonatomic, copy) MPInterstitialAdapterDelegateHandlerBlock didReceiveTapEvent;
@property (nonatomic, copy) MPInterstitialAdapterDelegateHandlerBlock didReceiveImpressionEvent;
@property (nonatomic, copy) MPInterstitialAdapterDelegateHandlerBlock willLeaveApplication;

@end
