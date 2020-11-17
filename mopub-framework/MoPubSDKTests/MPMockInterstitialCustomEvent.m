//
//  MPMockInterstitialCustomEvent.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockInterstitialCustomEvent.h"

@interface MPMockInterstitialCustomEvent()
@property (nonatomic, readwrite) BOOL isLocalExtrasAvailableAtRequest;
@end

@implementation MPMockInterstitialCustomEvent

- (instancetype)init {
    if (self = [super init]) {
        _isLocalExtrasAvailableAtRequest = NO;
    }

    return self;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.isLocalExtrasAvailableAtRequest = (self.localExtras != nil);

    if ([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didLoadAd:)]) {
        [self.delegate interstitialCustomEvent:self didLoadAd:[UIView new]];
    }
}

@end
