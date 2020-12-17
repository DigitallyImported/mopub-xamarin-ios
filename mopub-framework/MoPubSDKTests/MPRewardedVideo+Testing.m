//
//  MPRewardedVideo+Testing.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <objc/runtime.h>
#import "MPRewardedVideo+Testing.h"
#import "MPRewardedVideoAdManager.h"
#import "MPRewardedVideoAdManager+Testing.h"

@interface MPRewardedVideo() <MPRewardedVideoAdManagerDelegate>
- (void)startRewardedVideoConnectionWithUrl:(NSURL *)url;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation MPRewardedVideo (Testing)
@dynamic delegateTable;
@dynamic rewardedVideoAdManagers;

#pragma mark - Properties
static void(^sDidSendServerToServerCallbackUrl)(NSURL * url) = nil;

+ (void)setDidSendServerToServerCallbackUrl:(void(^)(NSURL * url))callback
{
    sDidSendServerToServerCallbackUrl = [callback copy];
}

+ (void(^)(NSURL * url))didSendServerToServerCallbackUrl
{
    return sDidSendServerToServerCallbackUrl;
}

#pragma mark - Life Cycle

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(startRewardedVideoConnectionWithUrl:);
        SEL swizzledSelector = @selector(testing_startRewardedVideoConnectionWithUrl:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Public Methods

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID withTestConfiguration:(MPAdConfiguration *)config {
    MPRewardedVideo *sharedInstance = [MPRewardedVideo sharedInstance];
    MPRewardedVideoAdManager * adManager = sharedInstance.rewardedVideoAdManagers[adUnitID];

    if (!adManager) {
        adManager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:adUnitID delegate:sharedInstance];
        sharedInstance.rewardedVideoAdManagers[adUnitID] = adManager;
    }

    [adManager loadWithConfiguration:config];
}

+ (MPRewardedVideoAdManager *)adManagerForAdUnitId:(NSString *)adUnitID {
    MPRewardedVideo *sharedInstance = [MPRewardedVideo sharedInstance];
    MPRewardedVideoAdManager * adManager = sharedInstance.rewardedVideoAdManagers[adUnitID];

    return adManager;
}

+ (MPRewardedVideoAdManager *)makeAdManagerForAdUnitId:(NSString *)adUnitId {
    MPRewardedVideoAdManager * manager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:adUnitId delegate:MPRewardedVideo.sharedInstance];
    MPRewardedVideo *sharedInstance = [MPRewardedVideo sharedInstance];
    sharedInstance.rewardedVideoAdManagers[adUnitId] = manager;

    return manager;
}

#pragma mark - Swizzles

- (void)testing_startRewardedVideoConnectionWithUrl:(NSURL *)url {
    if (sDidSendServerToServerCallbackUrl != nil) {
        sDidSendServerToServerCallbackUrl(url);
    }
}

@end
#pragma clang diagnostic pop
