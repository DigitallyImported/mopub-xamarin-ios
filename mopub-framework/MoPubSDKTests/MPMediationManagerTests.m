//
//  MPMediationManagerTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MoPub.h"
#import "MPMediationManager.h"
#import "MPMediationManager+Testing.h"
#import "MPMockAdColonyAdapterConfiguration.h"
#import "MPMockChartboostAdapterConfiguration.h"
#import "MPMockTapjoyAdapterConfiguration.h"

static const NSTimeInterval kTestTimeout = 2; // seconds

@interface MPMediationManagerTests : XCTestCase

@end

@implementation MPMediationManagerTests

- (void)setUp {
    [super setUp];
    [MPMediationManager.sharedManager clearCache];
    MPMockAdColonyAdapterConfiguration.isSdkInitialized = NO;
    MPMockChartboostAdapterConfiguration.isSdkInitialized = NO;
    MPMockTapjoyAdapterConfiguration.isSdkInitialized = NO;
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Network SDK Initialization

- (void)testInitialization {
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Put data into the cache to simulate having been cache prior.
    [MPMediationManager.sharedManager setCachedInitializationParameters:@{ @"appId": @"aaaa" } forNetwork:MPMockAdColonyAdapterConfiguration.class];
    [MPMediationManager.sharedManager setCachedInitializationParameters:@{ @"appId": @"bbbb" } forNetwork:MPMockChartboostAdapterConfiguration.class];
    [MPMediationManager.sharedManager setCachedInitializationParameters:@{ @"appId": @"cccc" } forNetwork:MPMockTapjoyAdapterConfiguration.class];

    // Initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Mediation initialization"];
    [MPMediationManager.sharedManager initializeWithAdditionalProviders:[NSArray arrayWithObject:MPMockTapjoyAdapterConfiguration.class] configurations:nil requestOptions:nil complete:^(NSError * _Nullable error, NSArray<id<MPAdapterConfiguration>> * _Nullable initializedAdapters) {
        [expectation fulfill];
    }];

    // Wait for SDKs to initialize
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify initialized adapters
    XCTAssertTrue(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertTrue(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertTrue(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    NSDictionary * adRequestPayload = MPMediationManager.sharedManager.adRequestPayload;
    XCTAssertNotNil(adRequestPayload);
    XCTAssertNotNil(adRequestPayload[@"mock_adcolony"]);
    XCTAssertNotNil(adRequestPayload[@"mock_chartboost"]);
    XCTAssertNotNil(adRequestPayload[@"mock_tapjoy"]);

    NSDictionary * advancedBiddingTokens = MPMediationManager.sharedManager.advancedBiddingTokens;
    XCTAssertNotNil(advancedBiddingTokens);
    XCTAssertNotNil(advancedBiddingTokens[@"mock_adcolony"]);
    XCTAssertNotNil(advancedBiddingTokens[@"mock_chartboost"]);
    XCTAssertNil(advancedBiddingTokens[@"mock_tapjoy"]);
    XCTAssertNotNil(advancedBiddingTokens[@"mock_adcolony"][@"token"]);
    XCTAssertNotNil(advancedBiddingTokens[@"mock_chartboost"][@"token"]);
    XCTAssertNil(advancedBiddingTokens[@"mock_tapjoy"][@"token"]);
}

- (void)testNoInitialization {
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    MPMediationManager.sharedManager.adapters = [NSMutableDictionary dictionary];

    NSDictionary * adapterPayload = MPMediationManager.sharedManager.adRequestPayload;
    XCTAssertNil(adapterPayload);
}

- (void)testNetworkSDKInitializationNotInCache {
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);

    // Initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Mediation initialization"];
    [MPMediationManager.sharedManager initializeWithAdditionalProviders:nil configurations:nil requestOptions:nil complete:^(NSError * _Nullable error, NSArray<id<MPAdapterConfiguration>> * _Nullable initializedAdapters) {
        [expectation fulfill];
    }];

    // Wait for SDKs to initialize
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
}

- (void)testNetworkSDKInitializationSuccess {
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);

    // Set an entry in the cache to indicate that it was previously initialized on-demand
    [MPMediationManager.sharedManager setCachedInitializationParameters:@{ @"poop": @"poop" } forNetwork:MPMockAdColonyAdapterConfiguration.class];

    // Initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Mediation initialization"];
    [MPMediationManager.sharedManager initializeWithAdditionalProviders:nil configurations:nil requestOptions:nil complete:^(NSError * _Nullable error, NSArray<id<MPAdapterConfiguration>> * _Nullable initializedAdapters) {
        [expectation fulfill];
    }];

    // Wait for SDKs to initialize
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
}

- (void)testNoNetworkSDKInitialization {
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Change the plist source to the production version so that nothing will load.
    MPMediationManager.adapterInformationProvidersFilePath = @"MPAdapters.plist";

    XCTestExpectation * expectation = [self expectationWithDescription:@"Mediation initialization"];
    [MPMediationManager.sharedManager initializeWithAdditionalProviders:nil configurations:nil requestOptions:nil complete:^(NSError * _Nullable error, NSArray<id<MPAdapterConfiguration>> * _Nullable initializedAdapters) {
        [expectation fulfill];
    }];

    // Wait for SDKs to initialize
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);
}

#pragma mark - Caching

- (void)testSetCacheSuccess {
    NSDictionary * params = @{ @"appId": @"adcolony_app_id",
                               @"zones": @[@"zone 1", @"zone 2"],
                               };

    [MPMediationManager.sharedManager setCachedInitializationParameters:params forNetwork:MPMockTapjoyAdapterConfiguration.class];

    NSDictionary * cachedParams = [MPMediationManager.sharedManager cachedInitializationParametersForNetwork:MPMockTapjoyAdapterConfiguration.class];
    XCTAssertNotNil(cachedParams);

    NSString * appId = cachedParams[@"appId"];
    XCTAssertNotNil(appId);
    XCTAssertTrue([appId isEqualToString:@"adcolony_app_id"]);

    NSArray * zones = cachedParams[@"zones"];
    XCTAssertNotNil(zones);
    XCTAssertTrue(zones.count == 2);
    XCTAssertTrue([zones[0] isEqualToString:@"zone 1"]);
    XCTAssertTrue([zones[1] isEqualToString:@"zone 2"]);
}

- (void)testSetCacheNoNetwork {
    NSDictionary * params = @{ @"appId": @"admob_app_id" };

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an error state.
    [MPMediationManager.sharedManager setCachedInitializationParameters:params forNetwork:nil];
#pragma clang diagnostic pop

    NSDictionary * cachedParams = [MPMediationManager.sharedManager cachedInitializationParametersForNetwork:MPMockTapjoyAdapterConfiguration.class];
    XCTAssertNil(cachedParams);
}

- (void)testSetCacheNoParams {
    [MPMediationManager.sharedManager setCachedInitializationParameters:nil forNetwork:MPMockTapjoyAdapterConfiguration.class];

    NSDictionary * cachedParams = [MPMediationManager.sharedManager cachedInitializationParametersForNetwork:MPMockTapjoyAdapterConfiguration.class];
    XCTAssertNil(cachedParams);
}

- (void)testClearCache {
    NSDictionary * params = @{ @"appId": @"tapjpy_app_id" };

    [MPMediationManager.sharedManager setCachedInitializationParameters:params forNetwork:MPMockTapjoyAdapterConfiguration.class];

    NSDictionary * cachedParams = [MPMediationManager.sharedManager cachedInitializationParametersForNetwork:MPMockTapjoyAdapterConfiguration.class];
    XCTAssertNotNil(cachedParams);

    [MPMediationManager.sharedManager clearCache];

    cachedParams = [MPMediationManager.sharedManager cachedInitializationParametersForNetwork:MPMockTapjoyAdapterConfiguration.class];
    XCTAssertNil(cachedParams);
}

#pragma mark - Initialization Parameters

- (void)testCachedParametersNoOverrides {
    // Put data into the cache to simulate having been cache prior.
    [MPMediationManager.sharedManager setCachedInitializationParameters:@{ @"appId": @"aaaa" } forNetwork:MPMockAdColonyAdapterConfiguration.class];

    // Retrieve initialization parameters
    MPMockAdColonyAdapterConfiguration * adapter = [MPMockAdColonyAdapterConfiguration new];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull" // intentional nil test
    NSDictionary<NSString *, NSString *> * params = [MPMediationManager.sharedManager parametersForAdapter:adapter overrideConfiguration:nil];
#pragma clang diagnostic pop

    XCTAssertNotNil(params);
    XCTAssert([params[@"appId"] isEqualToString:@"aaaa"]);
}

- (void)testNoCachedParametersAndOverrides {
    // Override parameters
    NSDictionary<NSString *, NSString *> * override = @{ @"animal": @"cat" };

    // Retrieve initialization parameters
    MPMockAdColonyAdapterConfiguration * adapter = [MPMockAdColonyAdapterConfiguration new];
    NSDictionary<NSString *, NSString *> * params = [MPMediationManager.sharedManager parametersForAdapter:adapter overrideConfiguration:override];

    XCTAssertNotNil(params);
    XCTAssert([params[@"animal"] isEqualToString:@"cat"]);
}

- (void)testCachedParametersAndOverrides {
    // Put data into the cache to simulate having been cache prior.
    [MPMediationManager.sharedManager setCachedInitializationParameters:@{ @"appId": @"aaaa", @"pid": @"999" } forNetwork:MPMockAdColonyAdapterConfiguration.class];

    // Override parameters
    NSDictionary<NSString *, NSString *> * override = @{ @"animal": @"cat", @"pid": @"0" };

    // Retrieve initialization parameters
    MPMockAdColonyAdapterConfiguration * adapter = [MPMockAdColonyAdapterConfiguration new];
    NSDictionary<NSString *, NSString *> * params = [MPMediationManager.sharedManager parametersForAdapter:adapter overrideConfiguration:override];

    XCTAssertNotNil(params);
    XCTAssert([params[@"appId"] isEqualToString:@"aaaa"]);
    XCTAssert([params[@"animal"] isEqualToString:@"cat"]);
    XCTAssert([params[@"pid"] isEqualToString:@"0"]);
}

#pragma mark - Adapters Plist

- (void)testMockAdaptersPlistExists {
    MPMediationManager.adapterInformationProvidersFilePath = [[NSBundle bundleForClass:self.class] pathForResource:@"MPMockAdapters" ofType:@"plist"];

    NSSet<Class<MPAdapterConfiguration>> * certifiedAdapters = MPMediationManager.certifiedAdapterInformationProviderClasses;
    XCTAssert(certifiedAdapters.count == 2);
}

- (void)testMissingAdaptersPlist {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull" // intentional nil test
    MPMediationManager.adapterInformationProvidersFilePath = nil;
#pragma clang diagnostic pop

    NSSet<Class<MPAdapterConfiguration>> * certifiedAdapters = MPMediationManager.certifiedAdapterInformationProviderClasses;
    XCTAssert(certifiedAdapters.count == 0);
}

@end
