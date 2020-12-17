//
//  MPMockNativeCustomEvent.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockNativeCustomEvent.h"
#import "MPNativeAd.h"

@interface MPMockNativeCustomEvent()
@property (nonatomic, strong) MPNativeAd * nativeAd;
@property (nonatomic, readwrite) BOOL isLocalExtrasAvailableAtRequest;
@end

@implementation MPMockNativeCustomEvent

- (instancetype)init {
    if (self = [super init]) {
        _nativeAd = [[MPNativeAd alloc] initWithAdAdapter:nil];
        _isLocalExtrasAvailableAtRequest = NO;
        _simulatedLoadTimeInterval = 1.0;
    }

    return self;
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.isLocalExtrasAvailableAtRequest = (self.localExtras != nil);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.simulatedLoadTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(nativeCustomEvent:didLoadAd:)]) {
            [self.delegate nativeCustomEvent:self didLoadAd:self.nativeAd];
        }
    });
}

@end

@implementation MPMockNativeCustomEventView

- (UILabel *)nativeMainTextLabel
{
    return self.mainTextLabel;
}

- (UILabel *)nativeTitleTextLabel
{
    return self.titleLabel;
}

- (UILabel *)nativeCallToActionTextLabel
{
    return self.callToActionLabel;
}

- (UIImageView *)nativeIconImageView
{
    return self.iconImageView;
}

- (UIImageView *)nativeMainImageView
{
    return self.mainImageView;
}

- (UIImageView *)nativePrivacyInformationIconImageView
{
    return self.privacyInformationIconImageView;
}

@end
