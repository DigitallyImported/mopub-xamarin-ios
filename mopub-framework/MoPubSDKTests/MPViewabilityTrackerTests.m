//
//  MPViewabilityTrackerTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPViewabilityTracker.h"
#import "MPViewabilityTracker+Testing.h"
#import "MPWebView.h"

@interface MPViewabilityTrackerTests : XCTestCase

@property (nonatomic, strong) MPViewabilityTracker *tracker;
@property (nonatomic, strong) MPWebView *webView;

@end

@implementation MPViewabilityTrackerTests

- (void)setUp {
    [MPViewabilityTracker initialize];
    self.webView = [[MPWebView alloc] initWithFrame:CGRectZero];
    self.tracker = [[MPViewabilityTracker alloc] initWithAdView:self.webView
                                                        isVideo:NO
                                       startTrackingImmediately:NO];
}

- (void)tearDown {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDisableViewabilityTrackerNotification object:nil];
    self.webView = nil;
    self.tracker = nil;
}

- (void)testViewabilityOptionAll {
    MPViewabilityOption all = MPViewabilityOptionIAS | MPViewabilityOptionMoat;
    XCTAssertTrue(all == MPViewabilityOptionAll);
}

- (void)testImmediateStartTracking {
    self.tracker = [[MPViewabilityTracker alloc] initWithAdView:self.webView
                                                        isVideo:NO
                                       startTrackingImmediately:YES];
    XCTAssertTrue(self.tracker.isTracking);
}

- (void)testDeferredStartTracking {
    XCTAssertFalse(self.tracker.isTracking);
    [self.tracker startTracking];
    XCTAssertTrue(self.tracker.isTracking);
}

- (void)testStopTracking {
    XCTAssertFalse(self.tracker.isTracking);
    [self.tracker startTracking];
    XCTAssertTrue(self.tracker.isTracking);
    [self.tracker stopTracking];
    XCTAssertFalse(self.tracker.isTracking);
}

- (void)testStopTrackingWontChangeIfAlreadyStopped {
    XCTAssertFalse(self.tracker.isTracking);
    [self.tracker stopTracking];
    XCTAssertFalse(self.tracker.isTracking);
}

- (void)testStartTrackingWontChangeIfAlreadyStarted {
    [self.tracker startTracking];
    XCTAssertTrue(self.tracker.isTracking);
    [self.tracker startTracking];
    XCTAssertTrue(self.tracker.isTracking);
}

- (void)testViewabilityEnabled {
    // The only viewability vendor that is mocked for unit testing is IAS.
    // As such that should be the only viewability vendor enabled.
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);
}

- (void)testDisableViewability {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // Disable IAS tracking
    [MPViewabilityTracker disableViewability:MPViewabilityOptionIAS];

    // All viewability vendors should be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);

    // Initializing new webview should not result in tracking
    self.tracker = [[MPViewabilityTracker alloc] initWithAdView:self.webView isVideo:NO startTrackingImmediately:YES];
    XCTAssertFalse(self.tracker.isTracking);
}

- (void)testDisableViewabilityDeferred {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // Disable IAS tracking
    [MPViewabilityTracker disableViewability:MPViewabilityOptionIAS];

    // All viewability vendors should be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);

    // Initializing new webview should not result in tracking
    self.tracker = [[MPViewabilityTracker alloc] initWithAdView:self.webView isVideo:NO startTrackingImmediately:NO];
    XCTAssertFalse(self.tracker.isTracking);

    // Start tracking should not result in tracking since it's been disabled.
    [self.tracker startTracking];
    XCTAssertFalse(self.tracker.isTracking);
}

- (void)testDisableViewabilityPartway {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // Initializing new webview should not result in tracking
    self.tracker = [[MPViewabilityTracker alloc] initWithAdView:self.webView isVideo:NO startTrackingImmediately:NO];
    XCTAssertFalse(self.tracker.isTracking);

    // Disable IAS tracking
    [MPViewabilityTracker disableViewability:MPViewabilityOptionIAS];

    // All viewability vendors should be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);

    // Start tracking should not work
    [self.tracker startTracking];
    XCTAssertFalse(self.tracker.isTracking);
}

- (void)testDisableViewabilityWhileTracking {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // Initializing new webview should result in tracking
    self.tracker = [[MPViewabilityTracker alloc] initWithAdView:self.webView isVideo:NO startTrackingImmediately:YES];
    XCTAssertTrue(self.tracker.isTracking);

    // Disable IAS tracking
    [MPViewabilityTracker disableViewability:MPViewabilityOptionIAS];

    // All viewability vendors should be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);

    // Tracking should be stopped
    XCTAssertFalse(self.tracker.isTracking);
}

- (void)testDisableDifferentViewabilityVendor {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // Disable Moat tracking
    [MPViewabilityTracker disableViewability:MPViewabilityOptionMoat];

    // IAS should still be enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // Initializing new webview should result in tracking
    self.tracker = [[MPViewabilityTracker alloc] initWithAdView:self.webView isVideo:NO startTrackingImmediately:YES];
    XCTAssertTrue(self.tracker.isTracking);
}

- (void)testDisablingAnAlreadyDisabledViewabilityVendor {
    // Register notification listener
    __block BOOL disableTrackersNotificationFired = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:kDisableViewabilityTrackerNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        disableTrackersNotificationFired = YES;
    }];

    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // Disable IAS tracking
    [MPViewabilityTracker disableViewability:MPViewabilityOptionIAS];

    // All viewability vendors should be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);
    XCTAssertTrue(disableTrackersNotificationFired);

    // Disable IAS tracking again
    disableTrackersNotificationFired = NO;
    [MPViewabilityTracker disableViewability:MPViewabilityOptionIAS];

    // The notification should not have been fired.
    XCTAssertFalse(disableTrackersNotificationFired);
}

@end
