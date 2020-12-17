//
//  MPMockViewabilityAdapterAvid.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPViewabilityAdapter.h"

/**
 * This mock is named `MPViewabilityAdapterAvid` instead of `MPMockViewabilityAdapterAvid`
 * because `MPViewabilityTracker` is looking for that class name.
 */
@interface MPViewabilityAdapterAvid : NSObject <MPViewabilityAdapter>
@property (nonatomic, readonly) BOOL isTracking;

- (instancetype)initWithAdView:(UIView *)webView isVideo:(BOOL)isVideo startTrackingImmediately:(BOOL)startTracking;
- (void)startTracking;
- (void)stopTracking;
- (void)registerFriendlyObstructionView:(UIView *)view;

@end
