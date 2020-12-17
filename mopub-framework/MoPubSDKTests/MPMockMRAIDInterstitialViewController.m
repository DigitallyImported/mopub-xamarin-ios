//
//  MPMockMRAIDInterstitialViewController.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockMRAIDInterstitialViewController.h"

@interface MPMockMRAIDInterstitialViewController ()

@end

@implementation MPMockMRAIDInterstitialViewController

- (instancetype)init {
    return [self initWithAdConfiguration:nil];
}

- (void)startLoading {
    if ([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
        [self.delegate interstitialDidLoadAd:self];
    }
}

- (void)simulateDismiss {
    if ([self.delegate respondsToSelector:@selector(interstitialDidDisappear:)]) {
        [self.delegate interstitialDidDisappear:self];
    }
}

- (void)simulateTap {
    if ([self.delegate respondsToSelector:@selector(interstitialDidReceiveTapEvent:)]) {
        [self.delegate interstitialDidReceiveTapEvent:self];
    }
}

@end
