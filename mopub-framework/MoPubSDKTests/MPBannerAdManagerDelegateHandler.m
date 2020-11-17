//
//  MPBannerAdManagerDelegateHandler.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPBannerAdManagerDelegateHandler.h"

@implementation MPBannerAdManagerDelegateHandler

#pragma mark - MPBannerAdManagerDelegate

- (void)invalidateContentView {
    // Do nothing.
}

- (void)managerDidLoadAd:(UIView *)ad {
    if (self.didLoadAd != nil) { self.didLoadAd(); }
}

- (void)managerDidFailToLoadAdWithError:(NSError *)error {
    if (self.didFailToLoadAd != nil) { self.didFailToLoadAd(error); }
}

- (void)userActionWillBegin {
    if (self.willBeginUserAction != nil) { self.willBeginUserAction(); }
}

- (void)userActionDidFinish {
    if (self.didEndUserAction != nil) { self.didEndUserAction(); }
}

- (void)userWillLeaveApplication {
    if (self.willLeaveApplication != nil) { self.willLeaveApplication(); }
}

- (void)impressionDidFireWithImpressionData:(MPImpressionData *)impressionData {
    if (self.impressionDidFire != nil) { self.impressionDidFire(impressionData); }
}

@end
