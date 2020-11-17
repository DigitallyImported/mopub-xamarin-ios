//
//  MPMoPubNativeAdAdapter+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMoPubNativeAdAdapter.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPAdImpressionTimer.h"

@interface MPMoPubNativeAdAdapter (Testing)

@property (nonatomic) MPAdImpressionTimer *impressionTimer;
@property (nonatomic, strong) MPAdDestinationDisplayAgent *destinationDisplayAgent;

// Expose private methods for testing
- (void)displayContentForDAAIconTap;

@end
