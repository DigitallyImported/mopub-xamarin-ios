//
//  MPMockBannerCustomEvent.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockBannerCustomEvent.h"

@interface MPMockBannerCustomEvent()
@property (nonatomic, readwrite) BOOL isLocalExtrasAvailableAtRequest;
@end

@implementation MPMockBannerCustomEvent

- (instancetype)init {
    if (self = [super init]) {
        _isLocalExtrasAvailableAtRequest = NO;
    }

    return self;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.isLocalExtrasAvailableAtRequest = (self.localExtras != nil);

    if ([self.delegate respondsToSelector:@selector(bannerCustomEvent:didLoadAd:)]) {
        [self.delegate bannerCustomEvent:self didLoadAd:[UIView new]];
    }
}

@end
