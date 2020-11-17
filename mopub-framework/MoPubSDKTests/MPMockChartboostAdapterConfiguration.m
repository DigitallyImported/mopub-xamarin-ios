//
//  MPMockChartboostAdapterConfiguration.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockChartboostAdapterConfiguration.h"

static BOOL gInitialized = NO;

@implementation MPMockChartboostAdapterConfiguration

+ (BOOL)isSdkInitialized {
    return gInitialized;
}

+ (void)setIsSdkInitialized:(BOOL)isSdkInitialized {
    gInitialized = isSdkInitialized;
}

- (NSString *)adapterVersion {
    return @"1.2.3.4";
}

- (NSString *)biddingToken {
    return @"eJxFkVuP2yAQhf8Lz9gyGHCItA9gSENjY8uX7LpVhewoVbdK1qnS9KKq/73gbLWPM8z5zszhD7C6e6yaneuGWoM1gqDVbWsq64wCa0BUwlUm0ogkeBWRTK0iKRGNVJIyISjGSm8ABEWVi8LLwfHF9S14g3SmDG3GYp4ijJOEEoYZYX6kave6af0jQjHxdVNVnVbLCkZthH+QiCPKFY0IESwieSojSbGKtFRIM7HCiuVeWDoprNWN2+nBqwbMvxdn9OOw3T8XL/bL9CSvH57K24Tffxt+UzshiYbTa7/f/DyIh4ewsdq5XNRCmsJ0gfMxhQRSmEEOUQIRhohBlH0KhloZ0YXzWt3sTR4uDIS80dq6rTbvth1YM5ZBIOpa9qYIUaI48UOyt2pJ6jCf4/N8uU3xdTxfTsdrPE9fD3E517epXTricvGC3i7rJJ61qb1u5NOYjW92j0Z1W7BOMxoi9QPPVfgAb/w/3sW3FLvg6pmnoy/zqtHuDiRHPiYZ/+y7Stv2fjy+JxJw8zXIK6ULX/1aMcfIa1zBwKcQGDHnMQJ//wGFwpho";
}

- (NSString *)moPubNetworkName {
    return @"mock_chartboost";
}

- (NSString *)networkSdkVersion {
    return @"1.2.3";
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, NSString *> * _Nullable)configuration
                                  complete:(void(^ _Nullable)(NSError * _Nullable))complete {
    MPMockChartboostAdapterConfiguration.isSdkInitialized = (configuration != nil);
    complete(nil);
}

@end
