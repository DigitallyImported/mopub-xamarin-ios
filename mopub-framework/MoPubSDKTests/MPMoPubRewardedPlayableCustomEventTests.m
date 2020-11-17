//
//  MPMoPubRewardedPlayableCustomEventTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPMoPubRewardedPlayableCustomEvent.h"
#import "MPMoPubRewardedPlayableCustomEvent+Testing.h"
#import "MPMockMRAIDInterstitialViewController.h"
#import "MPPrivateRewardedVideoCustomEventDelegateHandler.h"

static const NSTimeInterval kTestTimeout   = 2; // seconds
static const NSTimeInterval kTimerDuration = 1; // seconds
static NSString * const     kAdUnitId      = @"db27f95103794600b7a976ce7a503ced";

@interface MPMoPubRewardedPlayableCustomEventTests : XCTestCase
@property (nonatomic, strong) MPAdConfiguration *adConfiguration;
@property (nonatomic, strong) MPMoPubRewardedPlayableCustomEvent *customEvent;
@property (nonatomic, strong) MPPrivateRewardedVideoCustomEventDelegateHandler *delegateHandler;
@property (nonatomic, strong) MPMockMRAIDInterstitialViewController *mockMRAIDInterstitial;
@end

@implementation MPMoPubRewardedPlayableCustomEventTests

- (void)setUp {
    [super setUp];

    self.adConfiguration = ({
        MPAdConfiguration * config = [MPAdConfiguration new];
        config.rewardedPlayableDuration = kTimerDuration;
        config.rewardedPlayableShouldRewardOnClick = YES;
        config;
    });

    self.mockMRAIDInterstitial = [MPMockMRAIDInterstitialViewController new];
    self.delegateHandler = [[MPPrivateRewardedVideoCustomEventDelegateHandler alloc] initWithAdUnitId:kAdUnitId configuration:self.adConfiguration];

    self.customEvent = ({
        MPMoPubRewardedPlayableCustomEvent * ce = [[MPMoPubRewardedPlayableCustomEvent alloc] initWithInterstitial:self.mockMRAIDInterstitial];
        ce.delegate = self.delegateHandler;
        ce;
    });
}

- (void)tearDown {
    self.customEvent.delegate = nil;
    self.customEvent = nil;
    self.delegateHandler = nil;
    self.mockMRAIDInterstitial = nil;

    [super tearDown];
}

// Tests that the mock MPMRAIDInterstitialViewController has been successfully integrated into
// the custom event.
- (void)testRequestAd {
    [self.customEvent requestRewardedVideoWithCustomEventInfo:nil];

    XCTAssertTrue(self.customEvent.hasAdAvailable);
}

- (void)testRewardOnCountdownExpiration {
    [self.customEvent requestRewardedVideoWithCustomEventInfo:nil];
    XCTAssertTrue(self.customEvent.hasAdAvailable);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for user to be rewarded at timer expiration."];
    self.delegateHandler.shouldRewardUser = ^void() {
        [expectation fulfill];
    };

    [self.customEvent presentRewardedVideoFromViewController:nil];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testRewardOnTap {
    [self.customEvent requestRewardedVideoWithCustomEventInfo:nil];
    XCTAssertTrue(self.customEvent.hasAdAvailable);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for user to be rewarded at tap event."];

    __block BOOL rewarded = NO;
    __block BOOL tapped = NO;
    self.delegateHandler.didReceiveTap = ^void() {
        tapped = YES;
        [expectation fulfill];
    };

    self.delegateHandler.shouldRewardUser = ^void() {
        rewarded = YES;
    };

    [self.customEvent presentRewardedVideoFromViewController:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTimerDuration / 2.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mockMRAIDInterstitial simulateTap];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(rewarded && tapped);
}

// Verifies that no reward is given on tap.
- (void)testNoRewardOnTap {
    self.adConfiguration.rewardedPlayableShouldRewardOnClick = NO;

    [self.customEvent requestRewardedVideoWithCustomEventInfo:nil];
    XCTAssertTrue(self.customEvent.hasAdAvailable);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timer to elapse."];

    __block BOOL rewarded = NO;
    __block BOOL tapped = NO;
    self.delegateHandler.didReceiveTap = ^void() {
        tapped = YES;
        [expectation fulfill];
    };

    self.delegateHandler.shouldRewardUser = ^void() {
        rewarded = YES;
    };

    [self.customEvent presentRewardedVideoFromViewController:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTimerDuration / 2.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mockMRAIDInterstitial simulateTap];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(!rewarded && tapped);
}

- (void)testInvalidDuration {
    // Set an invalid countdown timer duration. It is expected that if an invalid duration
    // is specified, the timer will use 30 seconds as a default.
    self.adConfiguration.rewardedPlayableDuration = -1;

    [self.customEvent requestRewardedVideoWithCustomEventInfo:nil];
    XCTAssertTrue(self.customEvent.hasAdAvailable);
    XCTAssertEqual(self.customEvent.countdownDuration, 30);
}

- (void)testDismissInterstitialStopsTimer {
    [self.customEvent requestRewardedVideoWithCustomEventInfo:nil];
    XCTAssertTrue(self.customEvent.hasAdAvailable);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial to be dismissed."];

    self.delegateHandler.didDisappear = ^void() {
        [expectation fulfill];
    };

    [self.customEvent presentRewardedVideoFromViewController:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTimerDuration / 2.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(self.customEvent.isCountdownActive);
        [self.mockMRAIDInterstitial simulateDismiss];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(self.customEvent.isCountdownActive);
}

@end
