//
//  MPMockViewabilityAdapterAvid.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockViewabilityAdapterAvid.h"

@interface MPViewabilityAdapterAvid()
@property (nonatomic, readwrite) BOOL isTracking;
@end

@implementation MPViewabilityAdapterAvid

- (instancetype)initWithAdView:(UIView *)webView isVideo:(BOOL)isVideo startTrackingImmediately:(BOOL)startTracking {
    if (self = [super init]) {
        _isTracking = startTracking;
    }

    return self;
}

- (void)startTracking {
    self.isTracking = YES;
}

- (void)stopTracking {
    self.isTracking = NO;
}

- (void)registerFriendlyObstructionView:(UIView *)view {

}

@end
