//
//  MPMockAdColonyAdapterConfiguration.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockAdColonyAdapterConfiguration.h"

static BOOL gInitialized = NO;

@implementation MPMockAdColonyAdapterConfiguration

+ (BOOL)isSdkInitialized {
    return gInitialized;
}

+ (void)setIsSdkInitialized:(BOOL)isSdkInitialized {
    gInitialized = isSdkInitialized;
}

- (NSString *)adapterVersion {
    return @"10.3.2.0";
}

- (NSString *)biddingToken {
    return @"1";
}

- (NSString *)moPubNetworkName {
    return @"mock_adcolony";
}

- (NSString *)networkSdkVersion {
    return @"10.3.2";
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, NSString *> * _Nullable)configuration
                                  complete:(void(^ _Nullable)(NSError * _Nullable))complete {
    MPMockAdColonyAdapterConfiguration.isSdkInitialized = (configuration != nil);
    complete(nil);
}

@end
