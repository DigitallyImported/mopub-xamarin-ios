//
//  MPRewardedVideoDelegateHandler.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoDelegateHandler.h"

@implementation MPRewardedVideoDelegateHandler

- (void)resetHandlers {
    self.didLoadAd = nil;
    self.didFailToLoadAd = nil;
    self.didExpireAd = nil;
    self.didFailToPlayAd = nil;
    self.willAppear = nil;
    self.didAppear = nil;
    self.willDisappear = nil;
    self.didDisappear = nil;
    self.didReceiveTap = nil;
    self.didReceiveImpression = nil;
    self.willLeaveApp = nil;
    self.shouldRewardUser = nil;
}

#pragma mark - MPRewardedVideoAdManagerDelegate

- (void)rewardedVideoDidLoadForAdManager:(MPRewardedVideoAdManager *)manager {
    if (self.didLoadAd != nil) { self.didLoadAd(); }
}

- (void)rewardedVideoDidFailToLoadForAdManager:(MPRewardedVideoAdManager *)manager error:(NSError *)error {
    if (self.didFailToLoadAd != nil) { self.didFailToLoadAd(); }
}

- (void)rewardedVideoDidExpireForAdManager:(MPRewardedVideoAdManager *)manager {
    if (self.didExpireAd != nil) { self.didExpireAd(); }
}

- (void)rewardedVideoDidFailToPlayForAdManager:(MPRewardedVideoAdManager *)manager error:(NSError *)error {
    if (self.didFailToPlayAd != nil) { self.didFailToPlayAd(); }
}

- (void)rewardedVideoWillAppearForAdManager:(MPRewardedVideoAdManager *)manager {
    if (self.willAppear != nil) { self.willAppear(); }
}

- (void)rewardedVideoDidAppearForAdManager:(MPRewardedVideoAdManager *)manager {
    if (self.didAppear != nil) { self.didAppear(); }
}

- (void)rewardedVideoWillDisappearForAdManager:(MPRewardedVideoAdManager *)manager {
    if (self.willDisappear != nil) { self.willDisappear(); }
}

- (void)rewardedVideoDidDisappearForAdManager:(MPRewardedVideoAdManager *)manager {
    if (self.didDisappear != nil) { self.didDisappear(); }
}

- (void)rewardedVideoDidReceiveTapEventForAdManager:(MPRewardedVideoAdManager *)manager {
    if (self.didReceiveTap != nil) { self.didReceiveTap(); }
}

- (void)rewardedVideoWillLeaveApplicationForAdManager:(MPRewardedVideoAdManager *)manager {
    if (self.willLeaveApp != nil) { self.willLeaveApp(); }
}

- (void)rewardedVideoShouldRewardUserForAdManager:(MPRewardedVideoAdManager *)manager reward:(MPRewardedVideoReward *)reward {
    if (self.shouldRewardUser != nil) { self.shouldRewardUser(reward); }
}

- (void)rewardedVideoAdManager:(MPRewardedVideoAdManager *)manager didReceiveImpressionEventWithImpressionData:(MPImpressionData *)impressionData {
    if (self.didReceiveImpression != nil) { self.didReceiveImpression(impressionData); }
}

#pragma mark - MPRewardedVideoDelegate

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID {
    if (self.didLoadAd != nil) { self.didLoadAd(); }
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    if (self.didFailToLoadAd != nil) { self.didFailToLoadAd(); }
}

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID {
    if (self.didExpireAd != nil) { self.didExpireAd(); }
}

- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    if (self.didFailToPlayAd != nil) { self.didFailToPlayAd(); }
}

- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID {
    if (self.willAppear != nil) { self.willAppear(); }
}

- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID {
    if (self.didAppear != nil) { self.didAppear(); }
}

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID {
    if (self.willDisappear != nil) { self.willDisappear(); }
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID {
    if (self.didDisappear != nil) { self.didDisappear(); }
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    if (self.didReceiveTap != nil) { self.didReceiveTap(); }
}

- (void)didTrackImpressionWithAdUnitID:(NSString *)adUnitID impressionData:(MPImpressionData *)impressionData {
    if (self.didReceiveImpression != nil) { self.didReceiveImpression(impressionData); }
}

- (void)rewardedVideoAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID {
    if (self.willLeaveApp != nil) { self.willLeaveApp(); }
}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward {
    if (self.shouldRewardUser != nil) { self.shouldRewardUser(reward); }
}

@end
