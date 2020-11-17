//
//  MOPUBNativeVideoAdConfigValuesTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MOPUBNativeVideoAdConfigValues.h"

@interface MOPUBNativeVideoAdConfigValuesTests : XCTestCase

@end

@implementation MOPUBNativeVideoAdConfigValuesTests

#pragma mark - Test impression min visible pixels/percent validity

- (void)testPixelsOnlyIsValid {
    MOPUBNativeVideoAdConfigValues *config = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50
                                                                                            pauseVisiblePercent:50
                                                                                     impressionMinVisiblePixels:1
                                                                                    impressionMinVisiblePercent:-1
                                                                                    impressionMinVisibleSeconds:1
                                                                                               maxBufferingTime:10
                                                                                                       trackers:nil];
    XCTAssertTrue(config.isValid);
}

- (void)testPercentageOnlyIsValid {
    MOPUBNativeVideoAdConfigValues *config = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50
                                                                                            pauseVisiblePercent:50
                                                                                     impressionMinVisiblePixels:-1
                                                                                    impressionMinVisiblePercent:50
                                                                                    impressionMinVisibleSeconds:1
                                                                                               maxBufferingTime:10
                                                                                                       trackers:nil];
    XCTAssertTrue(config.isValid);
}

- (void)testBothPixelsAndPercentageIsValid {
    MOPUBNativeVideoAdConfigValues *config = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50
                                                                                            pauseVisiblePercent:50
                                                                                     impressionMinVisiblePixels:1
                                                                                    impressionMinVisiblePercent:50
                                                                                    impressionMinVisibleSeconds:1
                                                                                               maxBufferingTime:10
                                                                                                       trackers:nil];
    XCTAssertTrue(config.isValid);
}

- (void)testInvalidPixelsAndInvalidPercentageResultsInInvalidConfig {
    MOPUBNativeVideoAdConfigValues *config = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50
                                                                                            pauseVisiblePercent:50
                                                                                     impressionMinVisiblePixels:-1
                                                                                    impressionMinVisiblePercent:-1
                                                                                    impressionMinVisibleSeconds:1
                                                                                               maxBufferingTime:10
                                                                                                       trackers:nil];
    XCTAssertFalse(config.isValid);
}

@end
