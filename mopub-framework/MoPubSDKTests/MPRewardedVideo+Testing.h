//
//  MPRewardedVideo+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideo.h"
#import "MPAdConfiguration.h"
#import "MPRewardedVideoAdManager+Testing.h"

@interface MPRewardedVideo (Testing)
@property (nonatomic, strong) NSMapTable<NSString *, id<MPRewardedVideoDelegate>> * delegateTable;
@property (nonatomic, strong) NSMutableDictionary * rewardedVideoAdManagers;

+ (MPRewardedVideo *)sharedInstance;
+ (void)setDidSendServerToServerCallbackUrl:(void(^)(NSURL * url))callback;
+ (void(^)(NSURL * url))didSendServerToServerCallbackUrl;

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID withTestConfiguration:(MPAdConfiguration *)config;
+ (MPRewardedVideoAdManager *)adManagerForAdUnitId:(NSString *)adUnitID;
+ (MPRewardedVideoAdManager *)makeAdManagerForAdUnitId:(NSString *)adUnitId;

- (void)rewardedVideoAdManager:(MPRewardedVideoAdManager *)manager didReceiveImpressionEventWithImpressionData:(MPImpressionData *)impressionData;

@end
