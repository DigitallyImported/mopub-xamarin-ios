//
//  MPPrivateRewardedVideoCustomEventDelegateHandler.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPPrivateRewardedVideoCustomEventDelegateHandler.h"

@interface MPPrivateRewardedVideoCustomEventDelegateHandler()
@property (nonatomic, copy) NSString * adUnitId;
@property (nonatomic, strong) MPAdConfiguration * adConfiguration;
@end

@implementation MPPrivateRewardedVideoCustomEventDelegateHandler

- (instancetype)initWithAdUnitId:(NSString *)adUnitId configuration:(MPAdConfiguration *)config {
    if (self = [super init]) {
        self.adUnitId = adUnitId;
        self.adConfiguration = config;
    }

    return self;
}

- (id<MPMediationSettingsProtocol>)instanceMediationSettingsForClass:(Class)aClass {
    return nil;
}

- (void)rewardedVideoDidLoadAdForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent {
    if (self.didLoadAd != nil) { self.didLoadAd(); }
}

- (void)rewardedVideoDidFailToLoadAdForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent error:(NSError *)error {
    if (self.didFailToLoadAd != nil) { self.didFailToLoadAd(); }
}

- (void)rewardedVideoDidExpireForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent {
    if (self.didExpireAd != nil) { self.didExpireAd(); }
}

- (void)rewardedVideoDidFailToPlayForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent error:(NSError *)error {

}

- (void)rewardedVideoWillAppearForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent {
    if (self.willAppear != nil) { self.willAppear(); }
}

- (void)rewardedVideoDidAppearForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent {
    if (self.didAppear != nil) { self.didAppear(); }
}

- (void)rewardedVideoWillDisappearForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent {
    if (self.willDisappear != nil) { self.willDisappear(); }
}

- (void)rewardedVideoDidDisappearForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent {
    if (self.didDisappear != nil) { self.didDisappear(); }
}

- (void)rewardedVideoWillLeaveApplicationForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent {
    if (self.willLeaveApp != nil) { self.willLeaveApp(); }
}

- (void)rewardedVideoDidReceiveTapEventForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent {
    if (self.didReceiveTap != nil) { self.didReceiveTap(); }
}

- (void)rewardedVideoShouldRewardUserForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent reward:(MPRewardedVideoReward *)reward {
    if (self.shouldRewardUser != nil) { self.shouldRewardUser(); }
}

- (NSString *)customerIdForRewardedVideoCustomEvent:(MPRewardedVideoCustomEvent *)customEvent {
    return nil;
}

- (void)trackImpression {

}

- (void)trackClick {

}

- (NSString *)adUnitId {
    return _adUnitId;
}

- (MPAdConfiguration *)configuration {
    return _adConfiguration;
}

@end
