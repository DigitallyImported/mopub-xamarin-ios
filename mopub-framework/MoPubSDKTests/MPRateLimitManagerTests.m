//
//  MPRateLimitManagerTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPRateLimitManager+Testing.h"

static NSTimeInterval const kTimeoutTime = 0.7;

@interface MPRateLimitManagerTests : XCTestCase

@end

@implementation MPRateLimitManagerTests

- (void)testSettingTimer {
    MPRateLimitManager * manager = [MPRateLimitManager sharedInstance];

    NSString * adUnitString = @"FAKE_ADUNIT";
    NSString * reasonString = @"Reason";
    NSInteger milliseconds = 400;

    [manager setRateLimitTimerWithAdUnitId:adUnitString
                              milliseconds:milliseconds
                                    reason:reasonString];

    XCTAssertTrue([manager isRateLimitedForAdUnitId:adUnitString]);
    XCTAssertNotNil(manager.configurationDictionary[adUnitString]);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rate limit to end"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((milliseconds + 50) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssertEqual(milliseconds, [manager lastRateLimitMillisecondsForAdUnitId:adUnitString]);
        XCTAssert([reasonString isEqualToString:[manager lastRateLimitReasonForAdUnitId:adUnitString]]);
        XCTAssertFalse([manager isRateLimitedForAdUnitId:adUnitString]);
    });

    [self waitForExpectations:@[expectation] timeout:kTimeoutTime];
}

- (void)testSettingMultipleSimultaneousTimers {
    MPRateLimitManager * manager = [MPRateLimitManager sharedInstance];

    NSString * adUnitString1 = @"FAKE_ADUNIT1";
    NSString * reasonString1 = @"Reason1";
    NSString * adUnitString2 = @"FAKE_ADUNIT2";
    NSString * reasonString2 = @"Reason2";
    NSInteger milliseconds = 400;

    [manager setRateLimitTimerWithAdUnitId:adUnitString1
                              milliseconds:milliseconds
                                    reason:reasonString1];

    [manager setRateLimitTimerWithAdUnitId:adUnitString2
                              milliseconds:milliseconds
                                    reason:reasonString2];

    XCTAssertTrue([manager isRateLimitedForAdUnitId:adUnitString1]);
    XCTAssertNotNil(manager.configurationDictionary[adUnitString1]);

    XCTAssertTrue([manager isRateLimitedForAdUnitId:adUnitString2]);
    XCTAssertNotNil(manager.configurationDictionary[adUnitString2]);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rate limit to end"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((milliseconds + 50) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssertEqual(milliseconds, [manager lastRateLimitMillisecondsForAdUnitId:adUnitString1]);
        XCTAssert([reasonString1 isEqualToString:[manager lastRateLimitReasonForAdUnitId:adUnitString1]]);
        XCTAssertFalse([manager isRateLimitedForAdUnitId:adUnitString1]);

        XCTAssertEqual(milliseconds, [manager lastRateLimitMillisecondsForAdUnitId:adUnitString2]);
        XCTAssert([reasonString2 isEqualToString:[manager lastRateLimitReasonForAdUnitId:adUnitString2]]);
        XCTAssertFalse([manager isRateLimitedForAdUnitId:adUnitString2]);
    });

    [self waitForExpectations:@[expectation] timeout:kTimeoutTime];
}

- (void)testSettingOneTimerWithValueAndAnotherWithZero {
    MPRateLimitManager * manager = [MPRateLimitManager sharedInstance];

    NSString * adUnitString1 = @"FAKE_ADUNIT1";
    NSString * reasonString1 = @"Reason1";
    NSString * adUnitString2 = @"FAKE_ADUNIT2";
    NSString * reasonString2 = @"Reason2";
    NSInteger milliseconds = 400;

    [manager setRateLimitTimerWithAdUnitId:adUnitString1
                              milliseconds:milliseconds
                                    reason:reasonString1];

    [manager setRateLimitTimerWithAdUnitId:adUnitString2
                              milliseconds:0
                                    reason:reasonString2];

    XCTAssertTrue([manager isRateLimitedForAdUnitId:adUnitString1]);
    XCTAssertNotNil(manager.configurationDictionary[adUnitString1]);

    XCTAssertFalse([manager isRateLimitedForAdUnitId:adUnitString2]);
    XCTAssertNotNil(manager.configurationDictionary[adUnitString2]);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rate limit to end"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((milliseconds + 50) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssertEqual(milliseconds, [manager lastRateLimitMillisecondsForAdUnitId:adUnitString1]);
        XCTAssert([reasonString1 isEqualToString:[manager lastRateLimitReasonForAdUnitId:adUnitString1]]);
        XCTAssertFalse([manager isRateLimitedForAdUnitId:adUnitString1]);

        XCTAssertEqual(0, [manager lastRateLimitMillisecondsForAdUnitId:adUnitString2]);
        XCTAssert([reasonString2 isEqualToString:[manager lastRateLimitReasonForAdUnitId:adUnitString2]]);
        XCTAssertFalse([manager isRateLimitedForAdUnitId:adUnitString2]);
    });

    [self waitForExpectations:@[expectation] timeout:kTimeoutTime];
}

- (void)testSettingMultipleSimultaneousWithDifferentValues {
    MPRateLimitManager * manager = [MPRateLimitManager sharedInstance];

    NSString * adUnitString1 = @"FAKE_ADUNIT1";
    NSString * reasonString1 = @"Reason1";
    NSInteger milliseconds1 = 400;
    NSString * adUnitString2 = @"FAKE_ADUNIT2";
    NSString * reasonString2 = @"Reason2";
    NSInteger milliseconds2 = 200;

    [manager setRateLimitTimerWithAdUnitId:adUnitString1
                              milliseconds:milliseconds1
                                    reason:reasonString1];

    [manager setRateLimitTimerWithAdUnitId:adUnitString2
                              milliseconds:milliseconds2
                                    reason:reasonString2];

    XCTAssertTrue([manager isRateLimitedForAdUnitId:adUnitString1]);
    XCTAssertNotNil(manager.configurationDictionary[adUnitString1]);

    XCTAssertTrue([manager isRateLimitedForAdUnitId:adUnitString2]);
    XCTAssertNotNil(manager.configurationDictionary[adUnitString2]);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rate limit to end"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((milliseconds2 + 50) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue([manager isRateLimitedForAdUnitId:adUnitString1]);

        XCTAssertEqual(milliseconds2, [manager lastRateLimitMillisecondsForAdUnitId:adUnitString2]);
        XCTAssert([reasonString2 isEqualToString:[manager lastRateLimitReasonForAdUnitId:adUnitString2]]);
        XCTAssertFalse([manager isRateLimitedForAdUnitId:adUnitString2]);
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((milliseconds1 + 50) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssertEqual(milliseconds1, [manager lastRateLimitMillisecondsForAdUnitId:adUnitString1]);
        XCTAssert([reasonString1 isEqualToString:[manager lastRateLimitReasonForAdUnitId:adUnitString1]]);
        XCTAssertFalse([manager isRateLimitedForAdUnitId:adUnitString1]);

        XCTAssertEqual(milliseconds2, [manager lastRateLimitMillisecondsForAdUnitId:adUnitString2]);
        XCTAssert([reasonString2 isEqualToString:[manager lastRateLimitReasonForAdUnitId:adUnitString2]]);
        XCTAssertFalse([manager isRateLimitedForAdUnitId:adUnitString2]);
    });

    [self waitForExpectations:@[expectation] timeout:kTimeoutTime];
}

- (void)testForAdUnitThatWasNeverAdded {
    MPRateLimitManager * manager = [MPRateLimitManager sharedInstance];

    NSString * adUnitId = @"MPRateLimitManagerTests.m: Please don't use this ad unit ID in any other test";

    XCTAssertFalse([manager isRateLimitedForAdUnitId:adUnitId]);
    XCTAssertEqual(0, [manager lastRateLimitMillisecondsForAdUnitId:adUnitId]);
    XCTAssertNil([manager lastRateLimitReasonForAdUnitId:adUnitId]);
}

- (void)testNilAdUnitDoesNotCrash {
    MPRateLimitManager * manager = [MPRateLimitManager sharedInstance];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil`
    [manager setRateLimitTimerWithAdUnitId:nil milliseconds:5.0 reason:@"hi"];
    XCTAssertFalse([manager isRateLimitedForAdUnitId:nil]);
    XCTAssertNil([manager lastRateLimitReasonForAdUnitId:nil]);
    XCTAssert([manager lastRateLimitMillisecondsForAdUnitId:nil] == 0.0);
#pragma clang diagnostic pop


}

@end
