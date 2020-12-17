//
//  MPBannerCustomEventAdapter+Testing.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPBannerCustomEventAdapter+Testing.h"
#import "MPBannerCustomEvent.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation MPBannerCustomEventAdapter (Testing)

@dynamic configuration;
@dynamic bannerCustomEvent;
@dynamic hasTrackedImpression;

- (void)loadAdWithConfiguration:(MPAdConfiguration *)configuration customEvent:(MPBannerCustomEvent *)customEvent {
    self.configuration = configuration;
    self.bannerCustomEvent = customEvent;
    self.hasTrackedImpression = NO;
}

@end
#pragma clang diagnostic pop
