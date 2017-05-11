//
//  AdColonyController.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdColony/AdColony.h>
#import "AdColonyController.h"
#import "AdColonyGlobalMediationSettings.h"
#import "MoPub.h"
#import "MPRewardedVideo.h"

typedef enum {
    INIT_STATE_UNKNOWN,
    INIT_STATE_INITIALIZED,
    INIT_STATE_INITIALIZING
} InitState;

@interface AdColonyController()

@property (atomic, assign) InitState initState;
@property (atomic, retain) NSArray *callbacks;

@end

@implementation AdColonyController

+ (void)initializeAdColonyCustomEventWithAppId:(NSString *)appId allZoneIds:(NSArray *)allZoneIds userId:(NSString *)userId callback:(void(^)())callback {
    AdColonyController *instance = [AdColonyController sharedInstance];

    @synchronized (instance) {
        if (instance.initState == INIT_STATE_INITIALIZED) {
            if (callback) {
                callback();
            }
        } else {
            instance.callbacks = [instance.callbacks arrayByAddingObject:callback];

            if (instance.initState != INIT_STATE_INITIALIZING) {
                instance.initState = INIT_STATE_INITIALIZING;

                AdColonyGlobalMediationSettings *settings = [[MoPub sharedInstance] globalMediationSettingsForClass:[AdColonyGlobalMediationSettings class]];
                AdColonyAppOptions *options = [AdColonyAppOptions new];

                if (userId && userId.length > 0) {
                    options.userID = userId;
                } else if (settings && settings.customId.length > 0) {
                    options.userID = settings.customId;
                }

                [AdColony configureWithAppID:appId zoneIDs:allZoneIds options:options completion:^(NSArray<AdColonyZone *> * _Nonnull zones) {
                    @synchronized (instance) {
                        instance.initState = INIT_STATE_INITIALIZED;
                        for (void(^localCallback)() in instance.callbacks) {
                            localCallback();
                        }
                    }
                }];
            }
        }
    }
}

+ (AdColonyController *)sharedInstance {
    static dispatch_once_t onceToken;
    static AdColonyController *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [AdColonyController new];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _initState = INIT_STATE_UNKNOWN;
        _callbacks = @[];
    }
    return self;
}

@end
