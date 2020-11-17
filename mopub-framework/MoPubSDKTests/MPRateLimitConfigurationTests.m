//
//  MPRateLimitConfigurationTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPRateLimitConfiguration+Testing.h"

static NSTimeInterval const kTimeoutTime = 0.7;

@interface MPRateLimitConfigurationTests : XCTestCase

@end

@implementation MPRateLimitConfigurationTests

- (void)testDefaults {
    MPRateLimitConfiguration * config = [[MPRateLimitConfiguration alloc] init];

    XCTAssertNil(config.lastRateLimitReason);
    XCTAssertEqual(0, config.lastRateLimitMilliseconds);
    XCTAssertFalse(config.isRateLimited);
    XCTAssertNil(config.timer);
}

- (void)testSettingTimerWithNoValueAndNoReason {
    MPRateLimitConfiguration * config = [[MPRateLimitConfiguration alloc] init];

    [config setRateLimitTimerWithMilliseconds:0 reason:nil];

    XCTAssertNil(config.lastRateLimitReason);
    XCTAssertEqual(0, config.lastRateLimitMilliseconds);
    XCTAssertFalse(config.isRateLimited);
    XCTAssertNil(config.timer);
}

- (void)testSettingTimerWithNegativeValueAndNoReason {
    MPRateLimitConfiguration * config = [[MPRateLimitConfiguration alloc] init];

    [config setRateLimitTimerWithMilliseconds:-5 reason:nil]; // Should evaluate to 0

    XCTAssertNil(config.lastRateLimitReason);
    XCTAssertEqual(0, config.lastRateLimitMilliseconds);
    XCTAssertFalse(config.isRateLimited);
    XCTAssertNil(config.timer);
}

- (void)testSettingTimerWithNoValueAndReason {
    MPRateLimitConfiguration * config = [[MPRateLimitConfiguration alloc] init];

    NSString * reason = @"Reason";

    [config setRateLimitTimerWithMilliseconds:0 reason:reason];

    XCTAssert([config.lastRateLimitReason isEqualToString:reason]);
    XCTAssertEqual(0, config.lastRateLimitMilliseconds);
    XCTAssertFalse(config.isRateLimited);
    XCTAssertNil(config.timer);
}

- (void)testSettingTimerWithValueAndReason {
    MPRateLimitConfiguration * config = [[MPRateLimitConfiguration alloc] init];

    NSInteger milliseconds = 400;
    NSString * reason = @"Reason";

    [config setRateLimitTimerWithMilliseconds:milliseconds reason:reason];
    XCTAssertTrue(config.isRateLimited);
    XCTAssertNotNil(config.timer);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rate limit to end"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((milliseconds + 50) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssertFalse(config.isRateLimited);
        XCTAssertEqual(milliseconds, config.lastRateLimitMilliseconds);
        XCTAssert([reason isEqualToString:config.lastRateLimitReason]);
        XCTAssertNil(config.timer);
    });

    [self waitForExpectations:@[expectation] timeout:kTimeoutTime];
}

- (void)testSettingTimerWithValueAndNoReason {
    MPRateLimitConfiguration * config = [[MPRateLimitConfiguration alloc] init];

    NSInteger milliseconds = 400;

    [config setRateLimitTimerWithMilliseconds:milliseconds reason:nil];
    XCTAssertTrue(config.isRateLimited);
    XCTAssertNotNil(config.timer);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rate limit to end"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((milliseconds + 50) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssertFalse(config.isRateLimited);
        XCTAssertEqual(milliseconds, config.lastRateLimitMilliseconds);
        XCTAssertNil(config.lastRateLimitReason);
        XCTAssertNil(config.timer);
    });

    [self waitForExpectations:@[expectation] timeout:kTimeoutTime];
}

- (void)testSettingTimerWithValueAndReasonThenOverwritingWithNoValueAndNoReason {
    MPRateLimitConfiguration * config = [[MPRateLimitConfiguration alloc] init];

    NSInteger milliseconds = 400;
    NSString * reason = @"Reason";

    [config setRateLimitTimerWithMilliseconds:milliseconds reason:reason];
    XCTAssertTrue(config.isRateLimited);
    XCTAssertNotNil(config.timer);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rate limit to end"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((milliseconds + 50) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssertFalse(config.isRateLimited);
        XCTAssertEqual(milliseconds, config.lastRateLimitMilliseconds);
        XCTAssert([reason isEqualToString:config.lastRateLimitReason]);
        XCTAssertNil(config.timer);

        // set timer with no value and no reason and check
        [config setRateLimitTimerWithMilliseconds:0 reason:nil];
        XCTAssertNil(config.lastRateLimitReason);
        XCTAssertEqual(0, config.lastRateLimitMilliseconds);
        XCTAssertFalse(config.isRateLimited);
        XCTAssertNil(config.timer);

    });

    [self waitForExpectations:@[expectation] timeout:kTimeoutTime];
}

@end
