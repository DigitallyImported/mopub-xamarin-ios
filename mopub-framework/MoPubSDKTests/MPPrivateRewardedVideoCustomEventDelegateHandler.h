//
//  MPPrivateRewardedVideoCustomEventDelegateHandler.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPPrivateRewardedVideoCustomEventDelegate.h"

@interface MPPrivateRewardedVideoCustomEventDelegateHandler : NSObject <MPPrivateRewardedVideoCustomEventDelegate>
@property (nonatomic, copy) void(^didLoadAd)(void);
@property (nonatomic, copy) void(^didFailToLoadAd)(void);
@property (nonatomic, copy) void(^didExpireAd)(void);
@property (nonatomic, copy) void(^willAppear)(void);
@property (nonatomic, copy) void(^didAppear)(void);
@property (nonatomic, copy) void(^willDisappear)(void);
@property (nonatomic, copy) void(^didDisappear)(void);
@property (nonatomic, copy) void(^willLeaveApp)(void);
@property (nonatomic, copy) void(^didReceiveTap)(void);
@property (nonatomic, copy) void(^shouldRewardUser)(void);

- (instancetype)initWithAdUnitId:(NSString *)adUnitId configuration:(MPAdConfiguration *)config;
@end

