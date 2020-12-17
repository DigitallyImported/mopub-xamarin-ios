//
//  MPInterstitialAdapterDelegateHandler.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInterstitialAdapterDelegateHandler.h"

@implementation MPInterstitialAdapterDelegateHandler

- (void)adapterDidFinishLoadingAd:(MPBaseInterstitialAdapter *)adapter { if (self.didFinishLoadingAd) self.didFinishLoadingAd(adapter); }
- (void)adapter:(MPBaseInterstitialAdapter *)adapter didFailToLoadAdWithError:(NSError *)error { if (self.didFailToLoadAd) self.didFailToLoadAd(adapter, error); }
- (void)interstitialWillAppearForAdapter:(MPBaseInterstitialAdapter *)adapter { if (self.willAppear) self.willAppear(adapter); }
- (void)interstitialDidAppearForAdapter:(MPBaseInterstitialAdapter *)adapter { if (self.didAppear) self.didAppear(adapter); }
- (void)interstitialWillDisappearForAdapter:(MPBaseInterstitialAdapter *)adapter { if (self.willDisppear) self.willDisppear(adapter); }
- (void)interstitialDidDisappearForAdapter:(MPBaseInterstitialAdapter *)adapter { if (self.didDisppear) self.didDisppear(adapter); }
- (void)interstitialDidExpireForAdapter:(MPBaseInterstitialAdapter *)adapter { if (self.didExpire) self.didExpire(adapter); }
- (void)interstitialDidReceiveTapEventForAdapter:(MPBaseInterstitialAdapter *)adapter { if (self.didReceiveTapEvent) self.didReceiveTapEvent(adapter); }
- (void)interstitialWillLeaveApplicationForAdapter:(MPBaseInterstitialAdapter *)adapter { if (self.willLeaveApplication) self.willLeaveApplication(adapter); }
- (void)interstitialDidReceiveImpressionEventForAdapter:(MPBaseInterstitialAdapter *)adapter { if (self.didReceiveTapEvent) self.didReceiveTapEvent(adapter); }

@end
