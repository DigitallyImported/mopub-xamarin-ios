//
//  MPStubCustomEvent.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPStubCustomEvent.h"

static BOOL sIsInitialized = false;

@implementation MPStubCustomEvent

#pragma mark - Testing

+ (BOOL)isInitialized {
    return sIsInitialized;
}

+ (void)resetInitialization {
    sIsInitialized = false;
}

#pragma mark - MPRewardedVideoCustomEvent Overrides

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    sIsInitialized = true;
}

@end
