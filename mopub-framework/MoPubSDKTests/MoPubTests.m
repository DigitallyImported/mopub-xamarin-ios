//
//  MoPubTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MoPub.h"
#import "MoPub+Testing.h"
#import "MPAdConfiguration.h"
#import "MPMediationManager.h"
#import "MPMediationManager+Testing.h"
#import "MPMockAdColonyAdapterConfiguration.h"
#import "MPMockChartboostAdapterConfiguration.h"
#import "MPMockTapjoyAdapterConfiguration.h"
#import "MPWebView+Testing.h"
#import "MRController.h"
#import "MRController+Testing.h"

static NSTimeInterval const kTestTimeout = 2;

@interface MoPubTests : XCTestCase <MPRewardedVideoDelegate>

@end

@implementation MoPubTests

- (void)setUp {
    [super setUp];
    [MPMediationManager.sharedManager clearCache];

    [MoPub sharedInstance].forceWKWebView = NO;
    MPLogging.consoleLogLevel = MPBLogLevelInfo;
}

#pragma mark - Initialization

- (void)testInitializingNetworkFromCache {
    // Reset initialized state
    MPMockAdColonyAdapterConfiguration.isSdkInitialized = NO;
    MPMockChartboostAdapterConfiguration.isSdkInitialized = NO;
    MPMockTapjoyAdapterConfiguration.isSdkInitialized = NO;
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Put data into the cache to simulate having been cache prior.
    [MPMockAdColonyAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"aaaa" }];
    [MPMockChartboostAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"bbbb" }];
    [MPMockTapjoyAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"cccc" }];

    // Initialize
    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"fake_adunit_id"];
    config.additionalNetworks = nil;
    config.globalMediationSettings = nil;

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    [MoPub.sharedInstance setSdkWithConfiguration:config completion:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify initialized sdks
    XCTAssertTrue(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertTrue(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Verify adapter configurations exist
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockAdColonyAdapterConfiguration"]);
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockChartboostAdapterConfiguration"]);
    XCTAssertNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockTapjoyAdapterConfiguration"]);
}

- (void)testAdditionalInitializingNetworkFromCache {
    // Reset initialized state
    MPMockAdColonyAdapterConfiguration.isSdkInitialized = NO;
    MPMockChartboostAdapterConfiguration.isSdkInitialized = NO;
    MPMockTapjoyAdapterConfiguration.isSdkInitialized = NO;
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Put data into the cache to simulate having been cache prior.
    [MPMockAdColonyAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"aaaa" }];
    [MPMockChartboostAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"bbbb" }];
    [MPMockTapjoyAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"cccc" }];

    // Initialize
    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"fake_adunit_id"];
    config.additionalNetworks = [NSArray arrayWithObject:MPMockTapjoyAdapterConfiguration.class];
    config.globalMediationSettings = nil;

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    [MoPub.sharedInstance setSdkWithConfiguration:config completion:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify initialized sdks
    XCTAssertTrue(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertTrue(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertTrue(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Verify adapter configurations exist
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockAdColonyAdapterConfiguration"]);
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockChartboostAdapterConfiguration"]);
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockTapjoyAdapterConfiguration"]);
}

- (void)testNoInitializingNetworkFromCache {
    // Reset initialized state
    MPMockAdColonyAdapterConfiguration.isSdkInitialized = NO;
    MPMockChartboostAdapterConfiguration.isSdkInitialized = NO;
    MPMockTapjoyAdapterConfiguration.isSdkInitialized = NO;
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Remove data from the cache.
    [MPMediationManager.sharedManager clearCache];

    // Initialize
    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"fake_adunit_id"];
    config.additionalNetworks = nil;
    config.globalMediationSettings = nil;

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    [MoPub.sharedInstance setSdkWithConfiguration:config completion:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify initialized sdks
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Verify adapter configurations exist
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockAdColonyAdapterConfiguration"]);
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockChartboostAdapterConfiguration"]);
    XCTAssertNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockTapjoyAdapterConfiguration"]);
}

- (void)testInitializingWithLegitimateInterest {
    // Initialize
    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"fake_adunit_id"];
    config.allowLegitimateInterest = YES;

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    [MoPub.sharedInstance setSdkWithConfiguration:config completion:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify legitimate interest is set
    XCTAssertTrue(MoPub.sharedInstance.allowLegitimateInterest);
}

- (void)testInitializingWithoutLegitimateInterest {
    // Initialize
    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"fake_adunit_id"];

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    [MoPub.sharedInstance setSdkWithConfiguration:config completion:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify legitimate interest is not set by default
    XCTAssertFalse(MoPub.sharedInstance.allowLegitimateInterest);
}


#pragma mark - WKWebView

- (void)testNoForceWKWebView {
    // Normal WKWebView behavior
    [MoPub sharedInstance].forceWKWebView = NO;

    // Verify that UIWebView was used instead of WKWebView for video ads
    NSDictionary * headers = @{ kAdTypeMetadataKey: @"rewarded_video",
                                kIsVastVideoPlayerKey: @(1),
                                kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] }
                                };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    MRController * controller = [[MRController alloc] initWithAdViewFrame:CGRectZero supportedOrientations:MPInterstitialOrientationTypeAll adPlacementType:MRAdViewPlacementTypeInterstitial delegate:nil];
    [controller loadAdWithConfiguration:config];

    XCTAssertNil(controller.mraidWebView.wkWebView);
    XCTAssertNotNil(controller.mraidWebView.uiWebView);
}

- (void)testForceWKWebView {
    // Force WKWebView
    [MoPub sharedInstance].forceWKWebView = YES;

    // Verify that WKWebView was used instead of UIWebView for video ads
    NSDictionary * headers = @{ kAdTypeMetadataKey: @"rewarded_video",
                                kIsVastVideoPlayerKey: @(1),
                                kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] }
                                };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    MRController * controller = [[MRController alloc] initWithAdViewFrame:CGRectZero supportedOrientations:MPInterstitialOrientationTypeAll adPlacementType:MRAdViewPlacementTypeInterstitial delegate:nil];
    [controller loadAdWithConfiguration:config];

    XCTAssertNotNil(controller.mraidWebView.wkWebView);
    XCTAssertNil(controller.mraidWebView.uiWebView);
}

#pragma mark - Logging

- (void)testSetLogLevel {
    MPLogging.consoleLogLevel = MPBLogLevelDebug;

    XCTAssertTrue(MPLogging.consoleLogLevel == MPBLogLevelDebug);
}

@end
