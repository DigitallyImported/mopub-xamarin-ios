//
//  MPBannerAdManagerTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfigurationFactory.h"
#import "MPBannerAdManager.h"
#import "MPBannerAdManager+Testing.h"
#import "MPBannerAdManagerDelegateHandler.h"
#import "MPAdTargeting.h"
#import "MPBannerCustomEventAdapter.h"
#import "MPBannerCustomEventAdapter+Testing.h"
#import "MPMockAdServerCommunicator.h"
#import "MPMockBannerCustomEvent.h"
#import "MPAdServerKeys.h"

static const NSTimeInterval kDefaultTimeout = 10;

@interface MPBannerAdManagerTests : XCTestCase

@end

@implementation MPBannerAdManagerTests

#pragma mark - Networking

- (void)testEmptyConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^(NSError * error){
        [expectation fulfill];
    };

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    [manager communicatorDidReceiveAdConfigurations:@[]];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testNilConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^(NSError * error){
        [expectation fulfill];
    };

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    [manager communicatorDidReceiveAdConfigurations:nil];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testMultipleResponsesFirstSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^(NSError * error){
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerThatShouldLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    MPAdConfiguration * bannerLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    MPAdConfiguration * bannerLoadFail = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[bannerThatShouldLoad, bannerLoadThatShouldNotLoad, bannerLoadFail];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 1);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 1);
}

- (void)testMultipleResponsesMiddleSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^(NSError * error){
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerThatShouldLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    MPAdConfiguration * bannerLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    MPAdConfiguration * bannerLoadFail = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[bannerLoadFail, bannerThatShouldLoad, bannerLoadThatShouldNotLoad];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
}

- (void)testMultipleResponsesLastSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^(NSError * error){
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerThatShouldLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    MPAdConfiguration * bannerLoadFail1 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * bannerLoadFail2 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[bannerLoadFail1, bannerLoadFail2, bannerThatShouldLoad];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 3);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 3);
}

- (void)testMultipleResponsesFailOverToNextPage {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^(NSError * error){
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerLoadFail1 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * bannerLoadFail2 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[bannerLoadFail1, bannerLoadFail2];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}

- (void)testMultipleResponsesFailOverToNextPageClear {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^(NSError * error){
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerLoadFail1 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * bannerLoadFail2 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[bannerLoadFail1, bannerLoadFail2];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    communicator.mockConfigurationsResponse = @[[MPAdConfigurationFactory clearResponse]];

    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}

#pragma mark - Local Extras

- (void)testLocalExtrasInCustomEvent {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^(NSError * error){
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerThatShouldLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    NSArray * configurations = @[bannerThatShouldLoad];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    communicator.mockConfigurationsResponse = configurations;
    manager.communicator = communicator;

    MPAdTargeting * targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    targeting.localExtras = @{ @"testing": @"YES" };
    [manager loadAdWithTargeting:targeting];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    MPBannerCustomEventAdapter * adapter = (MPBannerCustomEventAdapter *)manager.onscreenAdapter;
    MPMockBannerCustomEvent * customEvent = (MPMockBannerCustomEvent *)adapter.bannerCustomEvent;
    XCTAssertNotNil(customEvent);

    NSDictionary * localExtras = customEvent.localExtras;
    XCTAssertNotNil(localExtras);
    XCTAssert([localExtras[@"testing"] isEqualToString:@"YES"]);
    XCTAssertTrue(customEvent.isLocalExtrasAvailableAtRequest);
}

#pragma mark - Impression Level Revenue Data

- (void)testImpressionDelegateFiresWithoutILRD {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for impression"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.impressionDidFire = ^(MPImpressionData * impresionData) {
        [expectation fulfill];

        XCTAssertNil(impresionData);
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerThatShouldLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    NSArray * configurations = @[bannerThatShouldLoad];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    communicator.mockConfigurationsResponse = configurations;
    manager.communicator = communicator;

    MPAdTargeting * targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    [manager loadAdWithTargeting:targeting];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testImpressionDelegateFiresWithILRD {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for impression"];

    NSString * adUnitIdSample = @"AD_UNIT_ID";

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.impressionDidFire = ^(MPImpressionData * impresionData) {
        [expectation fulfill];

        XCTAssertNotNil(impresionData);
        XCTAssert(impresionData.adUnitID == adUnitIdSample);
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerThatShouldLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    bannerThatShouldLoad.impressionData = [[MPImpressionData alloc] initWithDictionary:@{
                                                                                         kImpressionDataAdUnitIDKey: adUnitIdSample
                                                                                         }];
    NSArray * configurations = @[bannerThatShouldLoad];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    communicator.mockConfigurationsResponse = configurations;
    manager.communicator = communicator;

    MPAdTargeting * targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    [manager loadAdWithTargeting:targeting];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

@end
