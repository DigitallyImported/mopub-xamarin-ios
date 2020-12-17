//
//  MPCountdownTimerViewTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPCountdownTimerView+Testing.h"
#import "MPCountdownTimerView.h"

static const NSTimeInterval kTimerDurationInSeconds = 1;

// `NSTimer` is not totally accurate and it might be slower on build machines , thus we need some
// extra tolerance while waiting for the expections to be fulfilled.
static const NSTimeInterval kWaitTimeTolerance = 2;

@interface MPCountdownTimerViewTests : XCTestCase
@property (nonatomic, strong) MPCountdownTimerView * timerView;
@end

@implementation MPCountdownTimerViewTests

#pragma mark - Tests

// Test initialization with valid and invalid durations.
- (void)testInitialization {
    XCTAssertNotNil([[MPCountdownTimerView alloc] initWithDuration:100 timerCompletion:^(BOOL hasElapsed) {}]);
    XCTAssertNotNil([[MPCountdownTimerView alloc] initWithDuration:1 timerCompletion:^(BOOL hasElapsed) {}]);
    XCTAssertNil([[MPCountdownTimerView alloc] initWithDuration:0 timerCompletion:^(BOOL hasElapsed) {}]);
    XCTAssertNil([[MPCountdownTimerView alloc] initWithDuration:-1 timerCompletion:^(BOOL hasElapsed) {}]);
    XCTAssertNil([[MPCountdownTimerView alloc] initWithDuration:-100 timerCompletion:^(BOOL hasElapsed) {}]);
}

// Tests that the completion block for the timer executes after the timer has elapsed.
- (void)testElapses {
    XCTestExpectation * completionExpectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];
    __block BOOL completionCount = 0; // expected to be exactly 1
    MPCountdownTimerView * timerView = [[MPCountdownTimerView alloc] initWithDuration:kTimerDurationInSeconds timerCompletion:^(BOOL hasElapsed) {
        completionCount += 1;
        [completionExpectation fulfill];
    }];

    [timerView start];
    [self waitForExpectationsWithTimeout:kTimerDurationInSeconds * kWaitTimeTolerance handler:^(NSError * _Nullable error) {
        XCTAssertEqual(completionCount, 1, "Countdown timer completion block is not fired exactly once");
        XCTAssertNil(error);
    }];
}

// Test that attempting to start an already running timer before completion will do nothing.
- (void)testDoubleStartBeforeCompletion {
    XCTestExpectation * completionExpectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];
    __block BOOL completionCount = 0; // expected to be exactly 1
    MPCountdownTimerView * timerView = [[MPCountdownTimerView alloc] initWithDuration:kTimerDurationInSeconds timerCompletion:^(BOOL hasElapsed) {
        completionCount += 1;
        [completionExpectation fulfill];
    }];

    [timerView start];
    [timerView start]; // this redundant `start` should be ignore and has not effect
    [self waitForExpectationsWithTimeout:kTimerDurationInSeconds * kWaitTimeTolerance handler:^(NSError * _Nullable error) {
        XCTAssertEqual(completionCount, 1, "Countdown timer completion block is not fired exactly once");
        XCTAssertNil(error);
    }];

    // Now the completion is fired, wait a little longer to make sure the second `start` does nothing

    XCTestExpectation * emptyExpectation = [self expectationWithDescription:@"Nothing should happen, wait a little long to see"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTimerDurationInSeconds / 5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [emptyExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:kTimerDurationInSeconds * kWaitTimeTolerance handler:^(NSError * _Nullable error) {
        XCTAssertEqual(completionCount, 1, "Countdown timer completion block is not fired exactly once");
        XCTAssertNil(error);
    }];
}

// Test that starting a completed timer will do nothing
- (void)testStartAgainAfterCompletion {
    XCTestExpectation * completionExpectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];
    __block BOOL completionCount = 0; // expected to be exactly 1
    MPCountdownTimerView * timerView = [[MPCountdownTimerView alloc] initWithDuration:kTimerDurationInSeconds timerCompletion:^(BOOL hasElapsed) {
        completionCount += 1;
        [completionExpectation fulfill];
    }];

    [timerView start];
    [self waitForExpectationsWithTimeout:kTimerDurationInSeconds * kWaitTimeTolerance handler:^(NSError * _Nullable error) {
        XCTAssertEqual(completionCount, 1, "Countdown timer completion block is not fired exactly once");
        XCTAssertNil(error);
    }];

    // Now the completion is fired, calling `start` again should has no effect

    XCTestExpectation * emptyExpectation = [self expectationWithDescription:@"Nothing should happen, wait a little long to see"];
    [timerView start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTimerDurationInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [emptyExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:kTimerDurationInSeconds * kWaitTimeTolerance handler:^(NSError * _Nullable error) {
        XCTAssertEqual(completionCount, 1, "Countdown timer completion block is not fired exactly once");
        XCTAssertNil(error);
    }];
}

// Test the timer can be paused and resumed multiple times by notifications
- (void)testPauseAndResume {
    XCTestExpectation * completionExpectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];
    __block BOOL completionCount = 0; // expected to be exactly 1
    MPCountdownTimerView * timerView = [[MPCountdownTimerView alloc] initWithDuration:kTimerDurationInSeconds timerCompletion:^(BOOL hasElapsed) {
        completionCount += 1;
        [completionExpectation fulfill];
    }];
    timerView.notificationCenter = [NSNotificationCenter new];
    const NSTimeInterval kPauseSeconds = kTimerDurationInSeconds / 4;

    // nothing should happen before `start`
    [timerView.notificationCenter postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    XCTAssertFalse(timerView.timer.isCountdownActive);
    [timerView.notificationCenter postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    XCTAssertFalse(timerView.timer.isCountdownActive);

    [timerView start];
    XCTAssertTrue(timerView.timer.isCountdownActive);

    // pause
    [timerView.notificationCenter postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    XCTAssertFalse(timerView.timer.isCountdownActive);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kPauseSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // resume
        [timerView.notificationCenter postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
        XCTAssertTrue(timerView.timer.isCountdownActive);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kPauseSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // pause again
            [timerView.notificationCenter postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
            XCTAssertFalse(timerView.timer.isCountdownActive);

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kPauseSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // resume again
                [timerView.notificationCenter postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
                XCTAssertTrue(timerView.timer.isCountdownActive);
            });
        });
    });

    NSTimeInterval totalTime = kTimerDurationInSeconds + kPauseSeconds * 2; // paused twice
    [self waitForExpectationsWithTimeout:totalTime * kWaitTimeTolerance handler:^(NSError * _Nullable error) {
        XCTAssertEqual(completionCount, 1, "Countdown timer completion block is not fired exactly once");
        XCTAssertNil(error);
    }];

    XCTAssertFalse(timerView.timer.isCountdownActive);

    // nothing should happen after completion
    [timerView.notificationCenter postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    XCTAssertFalse(timerView.timer.isCountdownActive);
    [timerView.notificationCenter postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    XCTAssertFalse(timerView.timer.isCountdownActive);
}

// Test that the timer can stop and signal the completion block.
- (void)testStopAndSignal {
    XCTestExpectation * completionExpectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];
    __block BOOL completionCount = 0; // expected to be exactly 1
    MPCountdownTimerView * timerView = [[MPCountdownTimerView alloc] initWithDuration:kTimerDurationInSeconds timerCompletion:^(BOOL hasElapsed) {
        completionCount += 1;
        [completionExpectation fulfill];
    }];

    [timerView start];

    NSTimeInterval stopTime = kTimerDurationInSeconds / 2; // stop half way through
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(stopTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [timerView stopAndSignalCompletion:YES];
    });

    [self waitForExpectationsWithTimeout:kTimerDurationInSeconds * kWaitTimeTolerance handler:^(NSError * _Nullable error) {
        XCTAssertFalse(timerView.timer.isCountdownActive);
        XCTAssertEqual(completionCount, 1, "Countdown timer completion block is not fired exactly once");
        XCTAssertNil(error);
    }];
}

// Test that the timer can stop without signaling the completion block.
- (void)testStopAndNoSignal {
    XCTestExpectation * completionExpectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];
    __block BOOL completionCount = 0; // expected to be exactly 1
    MPCountdownTimerView * timerView = [[MPCountdownTimerView alloc] initWithDuration:kTimerDurationInSeconds timerCompletion:^(BOOL hasElapsed) {
        completionCount += 1; // should not happen
        [completionExpectation fulfill]; // should not happen
    }];

    [timerView start];

    NSTimeInterval stopTime = kTimerDurationInSeconds / 2; // stop half way through
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(stopTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [timerView stopAndSignalCompletion:NO];
        [completionExpectation fulfill];
    });

    [self waitForExpectationsWithTimeout:kTimerDurationInSeconds * kWaitTimeTolerance handler:^(NSError * _Nullable error) {
        XCTAssertFalse(timerView.timer.isCountdownActive);
        XCTAssertEqual(completionCount, 0, "Countdown timer completion block is fired unexpectedly");
        XCTAssertNil(error);
    }];
}

@end
