//
//  MPInterstitialAdController+Testing.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInterstitialAdController+Testing.h"

// Suppress warning of accessing private implementation `interstitialAdManager:didReceiveImpressionEventWithImpressionData:`
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation MPInterstitialAdController (Testing)
@dynamic manager;
@end
#pragma clang diagnostic pop
