//
//  MPBannerCustomEventAdapterTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPAdConfigurationFactory.h"
#import "MPBannerAdapterDelegateHandler.h"
#import "MPBannerCustomEvent.h"
#import "MPBannerCustomEventAdapter+Testing.h"
#import "MPConstants.h"
#import "MPError.h"
#import "MPHTMLBannerCustomEvent.h"
#import "MPMRAIDBannerCustomEvent.h"

@interface MPBannerCustomEventAdapterTests : XCTestCase

@end

@implementation MPBannerCustomEventAdapterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// When an AD is in the imp tracking experiment, banner impressions (include all banner formats) are fired from SDK.
- (void)testShouldTrackImpOnDisplayWhenExperimentEnabled {
    NSDictionary *headers = @{ kBannerImpressionVisableMsMetadataKey: @"0", kBannerImpressionMinPixelMetadataKey:@"1"};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeInline];

    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];

    adapter.configuration = config;

    [adapter didDisplayAd];

    XCTAssertFalse(adapter.hasTrackedImpression);
}

// When an AD is not in the imp tracking experiment, banner impressions are fired from SDK for base class.
- (void)testImpFiredWhenAutoTrackingEnabledForBaseBannerAndExperimentDisabled {
    MPAdConfiguration *config = [MPAdConfiguration new];

    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];
    adapter.configuration = config;

    MPBannerCustomEvent *customEvent = [MPBannerCustomEvent new];
    adapter.bannerCustomEvent = customEvent;
    adapter.hasTrackedImpression = NO;

    [adapter didDisplayAd];

    XCTAssertTrue(adapter.hasTrackedImpression);
}

// When an AD is not in the imp tracking experiment, banner impressions are fired from JS directly. SDK doesn't fire impression.
- (void)testImpFiredWhenAutoTrackingEnabledForHtmlAndExperimentDisabled {
    MPAdConfiguration *config = [MPAdConfiguration new];

    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];
    adapter.configuration = config;

    MPBannerCustomEvent *customEvent = [MPHTMLBannerCustomEvent new];
    adapter.bannerCustomEvent = customEvent;
    adapter.hasTrackedImpression = NO;

    [adapter didDisplayAd];

    XCTAssertFalse(adapter.hasTrackedImpression);
}

// When an AD is not in the imp tracking experiment, MRAID banner impressions are fired from SDK.
- (void)testImpFiredWhenAutoTrackingEnabledForMraidAndExperimentDisabled {
    MPAdConfiguration *config = [MPAdConfiguration new];

    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];
    adapter.configuration = config;

    MPBannerCustomEvent *customEvent = [MPMRAIDBannerCustomEvent new];
    adapter.bannerCustomEvent = customEvent;
    adapter.hasTrackedImpression = NO;

    [adapter didDisplayAd];

    XCTAssertTrue(adapter.hasTrackedImpression);
}

#pragma mark - Timeout

- (void)testTimeoutOverrideSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timeout"];

    // Generate the ad configurations
    MPAdConfiguration * bannerConfig = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent" additionalMetadata:@{kAdTimeoutMetadataKey: @(1000)}];

    // Configure handler
    __block BOOL didTimeout = NO;
    MPBannerAdapterDelegateHandler * handler = MPBannerAdapterDelegateHandler.new;
    handler.didFailToLoadAd = ^(NSError *error) {
        if (error != nil && error.code == MOPUBErrorAdRequestTimedOut) {
            didTimeout = YES;
        }

        [expectation fulfill];
    };

    // Adapter contains the timeout logic
    MPBannerCustomEventAdapter * adapter = [MPBannerCustomEventAdapter new];
    adapter.configuration = bannerConfig;
    adapter.delegate = handler;
    [adapter startTimeoutTimer];

    [self waitForExpectationsWithTimeout:BANNER_TIMEOUT_INTERVAL handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify error was timeout
    XCTAssertTrue(didTimeout);
}

@end
