//
//  MPAdImpressionTimerTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdImpressionTimer.h"

@interface MPAdImpressionTimer()

@property (nonatomic, assign) NSTimeInterval firstVisibilityTimestamp;

@end

@interface MPBannerAdImpressionTimerTests : XCTestCase

@property (nonatomic) MPAdImpressionTimer *impressionTimer;

@end

@implementation MPBannerAdImpressionTimerTests

- (void)setUp {
    [super setUp];
    self.impressionTimer = [[MPAdImpressionTimer alloc] initWithRequiredSecondsForImpression:0 requiredViewVisibilityPixels:1];
}

- (void)testTimerInitialization {
    XCTAssertEqual(self.impressionTimer.firstVisibilityTimestamp, -1);
}

@end
