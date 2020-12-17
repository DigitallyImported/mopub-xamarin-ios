//
//  MPNativeAdConfigValuesTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPNativeAdConfigValues.h"

@interface MPNativeAdConfigValuesTests : XCTestCase

@end

@implementation MPNativeAdConfigValuesTests

- (void)testValidationSuccessNormalPixels {
    MPNativeAdConfigValues *config;

    // 1 pixel for 1 second (invalid percent)
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:1
                                                    impressionMinVisiblePercent:-1
                                                    impressionMinVisibleSeconds:1];
    XCTAssert(config.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);

    // 1 pixel for 1 second (valid percent)
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:1
                                                    impressionMinVisiblePercent:50
                                                    impressionMinVisibleSeconds:1];
    XCTAssert(config.isImpressionMinVisiblePixelsValid);
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);
}

- (void)testValidationSuccessNormalPercentage {
    // 50% for 1 second
    MPNativeAdConfigValues *config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                                            impressionMinVisiblePercent:50
                                                                            impressionMinVisibleSeconds:1];
    XCTAssertFalse(config.isImpressionMinVisiblePixelsValid);
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);
}

- (void)testValidationSuccessEdges {
    MPNativeAdConfigValues *config;

    // 100% for 0.01 seconds
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                    impressionMinVisiblePercent:100
                                                    impressionMinVisibleSeconds:0.01];
    XCTAssertFalse(config.isImpressionMinVisiblePixelsValid);
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);

    // 0% for 0.01 seconds
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                    impressionMinVisiblePercent:0
                                                    impressionMinVisibleSeconds:0.01];
    XCTAssertFalse(config.isImpressionMinVisiblePixelsValid);
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);

    // 0 pixels for 0.01 seconds (invalid percentage)
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:0
                                                    impressionMinVisiblePercent:-1
                                                    impressionMinVisibleSeconds:0.01];
    XCTAssert(config.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);

    // 0 pixels for 0.01 seconds (valid percentage)
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:0
                                                    impressionMinVisiblePercent:0
                                                    impressionMinVisibleSeconds:0.01];
    XCTAssert(config.isImpressionMinVisiblePixelsValid);
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);
}

- (void)testValidationFailure {
    MPNativeAdConfigValues *config;

    // 50% for 0 seconds
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                    impressionMinVisiblePercent:50
                                                    impressionMinVisibleSeconds:0];
    XCTAssertFalse(config.isImpressionMinVisiblePixelsValid);
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(config.isImpressionMinVisibleSecondsValid);

    // 50% for -1 seconds
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                    impressionMinVisiblePercent:50
                                                    impressionMinVisibleSeconds:-1];
    XCTAssertFalse(config.isImpressionMinVisiblePixelsValid);
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(config.isImpressionMinVisibleSecondsValid);

    // 101% for 1 second
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                    impressionMinVisiblePercent:101
                                                    impressionMinVisibleSeconds:1];
    XCTAssertFalse(config.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);

    // -1% for 1 second
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                    impressionMinVisiblePercent:-1
                                                    impressionMinVisibleSeconds:1];
    XCTAssertFalse(config.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);

    // -1% for -1 seconds
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                    impressionMinVisiblePercent:-1
                                                    impressionMinVisibleSeconds:-1];
    XCTAssertFalse(config.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(config.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(config.isImpressionMinVisibleSecondsValid);

    // 1 pixel for -1 seconds (invalid percent)
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:1
                                                    impressionMinVisiblePercent:-1
                                                    impressionMinVisibleSeconds:-1];
    XCTAssert(config.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(config.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(config.isImpressionMinVisibleSecondsValid);

    // 1 pixel for -1 seconds (valid percent)
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:1
                                                    impressionMinVisiblePercent:1
                                                    impressionMinVisibleSeconds:-1];
    XCTAssert(config.isImpressionMinVisiblePixelsValid);
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(config.isImpressionMinVisibleSecondsValid);
}

@end
