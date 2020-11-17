//
//  MPMockRewardedVideoCustomEvent.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockRewardedVideoCustomEvent.h"

@interface MPMockRewardedVideoCustomEvent()
@property (nonatomic, readwrite) BOOL isLocalExtrasAvailableAtRequest;
@end

@implementation MPMockRewardedVideoCustomEvent

- (instancetype)init {
    if (self = [super init]) {
        _isLocalExtrasAvailableAtRequest = NO;
    }

    return self;
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.isLocalExtrasAvailableAtRequest = (self.localExtras != nil);

    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidLoadAdForCustomEvent:)]) {
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    }
}

@end
