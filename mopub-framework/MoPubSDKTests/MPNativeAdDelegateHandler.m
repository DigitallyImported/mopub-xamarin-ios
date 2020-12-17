//
//  MPNativeAdDelegateHandler.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPNativeAdDelegateHandler.h"

@implementation MPNativeAdDelegateHandler

- (void)willPresentModalForNativeAd:(MPNativeAd *)nativeAd {
    if (self.willPresentModal) { self.willPresentModal(nativeAd); }
}

- (void)didDismissModalForNativeAd:(MPNativeAd *)nativeAd {
    if (self.didPresentModal) { self.didPresentModal(nativeAd); }
}

- (void)willLeaveApplicationFromNativeAd:(MPNativeAd *)nativeAd {
    if (self.willLeaveApplication) { self.willLeaveApplication(nativeAd); };
}

- (UIViewController *)viewControllerForPresentingModalView {
    if (self.viewControllerForModal) { return self.viewControllerForModal(); }

    return [[UIViewController alloc] init];
}

- (void)mopubAd:(id<MPMoPubAd>)ad didTrackImpressionWithImpressionData:(MPImpressionData *)impressionData {
    if (self.didTrackImpression) { self.didTrackImpression((MPNativeAd *)ad, impressionData); }
}

@end
