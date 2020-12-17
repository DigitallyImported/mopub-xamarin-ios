//
//  MPRealTimeTimerTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPRealTimeTimer.h"

static NSTimeInterval const kTestTimeout = 4;
static NSTimeInterval const kTestLength = 2;
static NSTimeInterval const kTestTooLong = 10000;

@interface MPRealTimeTimerTests : XCTestCase

@property (strong, nonatomic) MPRealTimeTimer *timer;

@end

@implementation MPRealTimeTimerTests

- (void)tearDown {
    [super tearDown];
    self.timer = nil;
}

- (void)testBasicTimerFunction {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect timer to fire"];
    self.timer = [[MPRealTimeTimer alloc] initWithInterval:kTestLength block:^(MPRealTimeTimer *timer){
        [expectation fulfill];
    }];
    [self.timer scheduleNow];

    XCTAssertTrue(self.timer.isScheduled);

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(self.timer.isScheduled);
}

- (void)testImmediateFire {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect timer to fire"];
    self.timer = [[MPRealTimeTimer alloc] initWithInterval:kTestTooLong block:^(MPRealTimeTimer *timer){
        [expectation fulfill];
    }];
    [self.timer scheduleNow];

    XCTAssertTrue(self.timer.isScheduled);

    [self.timer fire];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(self.timer.isScheduled);
}

- (void)testInvalidate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect time to pass"];

    __block BOOL timerFired = NO;
    self.timer = [[MPRealTimeTimer alloc] initWithInterval:kTestLength block:^(MPRealTimeTimer *timer){
        timerFired = YES;
    }];
    [self.timer scheduleNow];
    XCTAssertTrue(self.timer.isScheduled);

    [self.timer invalidate];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssertFalse(timerFired);
    });

    [self waitForExpectationsWithTimeout:kTestTimeout * 2 handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertFalse(self.timer.isScheduled);
}

- (void)testTimerStillFiresAfterBackgroundingWithTimeLeftUponForeground {
    XCTestExpectation *fireExpectation = [self expectationWithDescription:@"Expect timer to fire"];
    XCTestExpectation *foregroundExpectation = [self expectationWithDescription:@"Expect foreground event"];

    __block BOOL timerFired = NO;
    self.timer = [[MPRealTimeTimer alloc] initWithInterval:kTestLength block:^(MPRealTimeTimer *timer){
        timerFired = YES;
        [fireExpectation fulfill];
    }];
    [self.timer scheduleNow];
    XCTAssertTrue(self.timer.isScheduled);

    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    XCTAssertFalse(timerFired);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTestLength / 2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
        [foregroundExpectation fulfill];

        XCTAssertFalse(timerFired);
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(timerFired);
    XCTAssertFalse(self.timer.isScheduled);
}

- (void)testTimerStillFiresAfterBackgroundingWithNoTimeLeftUponForeground {
    XCTestExpectation *fireExpectation = [self expectationWithDescription:@"Expect timer to fire"];
    XCTestExpectation *foregroundExpectation = [self expectationWithDescription:@"Expect foreground event"];

    __block BOOL timerFired = NO;
    self.timer = [[MPRealTimeTimer alloc] initWithInterval:kTestLength block:^(MPRealTimeTimer *timer){
        timerFired = YES;
        [fireExpectation fulfill];
    }];
    [self.timer scheduleNow];
    XCTAssertTrue(self.timer.isScheduled);

    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    XCTAssertFalse(timerFired);

    // we intentionally wait to foreground until after the timer should have fired
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTestLength + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
        [foregroundExpectation fulfill];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(timerFired);
    XCTAssertFalse(self.timer.isScheduled);
}

@end
