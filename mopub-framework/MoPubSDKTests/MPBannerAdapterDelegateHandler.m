//
//  MPBannerAdapterDelegateHandler.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPBannerAdapterDelegateHandler.h"

@implementation MPBannerAdapterDelegateHandler

- (void)adapter:(MPBaseBannerAdapter *)adapter didFailToLoadAdWithError:(NSError *)error {
    if (self.didFailToLoadAd != nil) { self.didFailToLoadAd(error); }
}

- (void)adapter:(MPBaseBannerAdapter *)adapter didFinishLoadingAd:(UIView *)ad {
    if (self.didLoadAd != nil) { self.didLoadAd(); }
}

- (void)userActionWillBeginForAdapter:(MPBaseBannerAdapter *)adapter {
    if (self.willBeginUserAction != nil) { self.willBeginUserAction(); }
}

- (void)userActionDidFinishForAdapter:(MPBaseBannerAdapter *)adapter {
    if (self.didFinishUserAction != nil) { self.didFinishUserAction(); }
}

- (void)userWillLeaveApplicationFromAdapter:(MPBaseBannerAdapter *)adapter {
    if (self.willLeaveApplication != nil) { self.willLeaveApplication(); }
}

- (void)adapterDidTrackImpressionForAd:(MPBaseBannerAdapter *)adapter {
    if (self.didTrackImpression != nil) { self.didTrackImpression(); }
}

- (void)adWillExpandForAdapter:(MPBaseBannerAdapter *)adapter {
    if (self.willExpand != nil) { self.willExpand(); }
}

- (void)adDidCollapseForAdapter:(MPBaseBannerAdapter *)adapter {
    if (self.didCollapse != nil) { self.didCollapse(); }
}

@end
