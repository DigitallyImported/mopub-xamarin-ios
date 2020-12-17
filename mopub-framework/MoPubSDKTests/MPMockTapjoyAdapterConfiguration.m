//
//  MPMockTapjoyAdapterConfiguration.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockTapjoyAdapterConfiguration.h"

static BOOL gInitialized = NO;

@implementation MPMockTapjoyAdapterConfiguration

+ (BOOL)isSdkInitialized {
    return gInitialized;
}

+ (void)setIsSdkInitialized:(BOOL)isSdkInitialized {
    gInitialized = isSdkInitialized;
}

- (NSString *)adapterVersion {
    return @"20.0.0.0";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"mock_tapjoy";
}

- (NSString *)networkSdkVersion {
    return @"20.0.0";
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, NSString *> * _Nullable)configuration
                                  complete:(void(^ _Nullable)(NSError * _Nullable))complete {
    MPMockTapjoyAdapterConfiguration.isSdkInitialized = (configuration != nil);
    complete(nil);
}

@end
