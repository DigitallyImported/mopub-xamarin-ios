//
//  MPAdView+Testing.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdView+Testing.h"

// Suppress warning of accessing private implementation `impressionDidFireWithImpressionData:`
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation MPAdView (Testing)
@dynamic adManager;
@end
#pragma clang diagnostic pop
