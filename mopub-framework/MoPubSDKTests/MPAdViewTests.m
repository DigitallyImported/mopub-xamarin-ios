//
//  MPAdViewTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdServerKeys.h"
#import "MPAdView.h"
#import "MPAdView+Testing.h"
#import "MPAPIEndpoints.h"
#import "MPBannerAdManager+Testing.h"
#import "MPError.h"
#import "MPLogging.h"
#import "MPLoggingHandler.h"
#import "MPMockAdServerCommunicator.h"
#import "MPURL.h"
#import "NSURLComponents+Testing.h"
#import "MPImpressionTrackedNotification.h"

static NSTimeInterval const kTestTimeout = 0.5;
static NSTimeInterval const kDefaultTimeout = 10;

@interface MPAdViewTests : XCTestCase
@property (nonatomic, strong) MPAdView * adView;
@property (nonatomic, weak) MPMockAdServerCommunicator * mockAdServerCommunicator;
@end

@implementation MPAdViewTests

- (void)setUp {
    [super setUp];

    self.adView = [[MPAdView alloc] initWithAdUnitId:@"FAKE_AD_UNIT_ID"];
    self.adView.adManager.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adView.adManager];
        self.mockAdServerCommunicator = mock;
        mock;
    });
}

#pragma mark - Viewability

- (void)testViewabilityQueryParameter {
    MPAdView * adView = [[MPAdView alloc] initWithAdUnitId:@"FAKE_AD_UNIT_ID"];
    MPMockAdServerCommunicator * mockAdServerCommunicator = nil;
    adView.adManager.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:adView.adManager];
        mockAdServerCommunicator = mock;
        mock;
    });

    // Banner ads should send a viewability query parameter.
    [adView loadAdWithMaxAdSize:kMPPresetMaxAdSize50Height];

    XCTAssertNotNil(mockAdServerCommunicator);
    XCTAssertNotNil(mockAdServerCommunicator.lastUrlLoaded);

    MPURL * url = [mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);

    NSString * viewabilityValue = [url stringForPOSTDataKey:kViewabilityStatusKey];
    XCTAssertNotNil(viewabilityValue);
    XCTAssertTrue([viewabilityValue isEqualToString:@"1"]);
}

#pragma mark - Ad Sizing

- (void)testRequestMatchFrameWithNoFrameWarningOnLoad {
    NSString * adUnitId = @"testRequestMatchFrameWithNoFrameWarningOnLoad";
    NSString * expectedWidthErrorMessage = NSError.frameWidthNotSetForFlexibleSize.localizedDescription;
    NSString * expectedHeightErrorMessage = NSError.frameHeightNotSetForFlexibleSize.localizedDescription;

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner warnings on load"];
    expectation.expectedFulfillmentCount = 2; // 2 warnings on load

    MPLoggingHandler * handler = [MPLoggingHandler handler:^(NSString * _Nullable message) {
        if (![message containsString:adUnitId]) {
            return;
        }

        if ([message containsString:expectedWidthErrorMessage]) {
            [expectation fulfill];
        }

        if ([message containsString:expectedHeightErrorMessage]) {
            [expectation fulfill];
        }
    }];

    [MPLogging addLogger:handler];

    MPAdView * noFrameBanner = [[MPAdView alloc] initWithAdUnitId:adUnitId];
    MPMockAdServerCommunicator * mockAdServerCommunicator = nil;
    noFrameBanner.adManager.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:noFrameBanner.adManager];
        mockAdServerCommunicator = mock;
        mock;
    });

    [noFrameBanner loadAdWithMaxAdSize:kMPPresetMaxAdSizeMatchFrame];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    [MPLogging removeLogger:handler];

    MPURL * url = [mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);
    NSNumber * cw = [url numberForPOSTDataKey:kCreativeSafeWidthKey];
    NSNumber * ch = [url numberForPOSTDataKey:kCreativeSafeHeightKey];
    XCTAssert(cw.floatValue == 0.0);
    XCTAssert(ch.floatValue == 0.0);
}

- (void)testRequestMatchFrameWithPartialFrameWarningOnLoad {
    NSString * adUnitId = @"testRequestMatchFrameWithPartialFrameWarningOnLoad";
    NSString * expectedHeightErrorMessage = NSError.frameHeightNotSetForFlexibleSize.localizedDescription;

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner warning on partial frame"];
    expectation.expectedFulfillmentCount = 1; // 1 warning on load

    MPLoggingHandler * handler = [MPLoggingHandler handler:^(NSString * _Nullable message) {
        if (![message containsString:adUnitId]) {
            return;
        }

        if ([message containsString:expectedHeightErrorMessage]) {
            [expectation fulfill];
        }
    }];

    [MPLogging addLogger:handler];

    MPAdView * partialFrameBanner = [[MPAdView alloc] initWithAdUnitId:adUnitId];
    partialFrameBanner.frame = CGRectMake(0, 0, 475, 0);
    MPMockAdServerCommunicator * mockAdServerCommunicator = nil;
    partialFrameBanner.adManager.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:partialFrameBanner.adManager];
        mockAdServerCommunicator = mock;
        mock;
    });

    [partialFrameBanner loadAdWithMaxAdSize:kMPPresetMaxAdSizeMatchFrame];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    [MPLogging removeLogger:handler];

    MPURL * url = [mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);
    NSNumber * sc = [url numberForPOSTDataKey:kScaleFactorKey];
    NSNumber * cw = [url numberForPOSTDataKey:kCreativeSafeWidthKey];
    NSNumber * ch = [url numberForPOSTDataKey:kCreativeSafeHeightKey];
    XCTAssert(cw.floatValue == 475.0 * sc.floatValue);
    XCTAssert(ch.floatValue == 0.0);
}

- (void)testRequestMatchFrameWithFrameNoWarningOnLoad {
    NSString * adUnitId = @"testRequestMatchFrameWithFrameNoWarningOnLoad";
    NSString * expectedWidthErrorMessage = NSError.frameWidthNotSetForFlexibleSize.localizedDescription;
    NSString * expectedHeightErrorMessage = NSError.frameHeightNotSetForFlexibleSize.localizedDescription;

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for no banner warnings"];
    expectation.inverted = YES;

    MPLoggingHandler * handler = [MPLoggingHandler handler:^(NSString * _Nullable message) {
        if (![message containsString:adUnitId]) {
            return;
        }

        if ([message containsString:expectedWidthErrorMessage]) {
            [expectation fulfill];
        }

        if ([message containsString:expectedHeightErrorMessage]) {
            [expectation fulfill];
        }
    }];

    [MPLogging addLogger:handler];

    MPAdView * frameBanner = [[MPAdView alloc] initWithAdUnitId:adUnitId];
    frameBanner.frame = CGRectMake(0, 0, 475, 250);
    MPMockAdServerCommunicator * mockAdServerCommunicator = nil;
    frameBanner.adManager.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:frameBanner.adManager];
        mockAdServerCommunicator = mock;
        mock;
    });

    [frameBanner loadAdWithMaxAdSize:kMPPresetMaxAdSizeMatchFrame];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:nil];

    [MPLogging removeLogger:handler];

    MPURL * url = [mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);
    NSNumber * sc = [url numberForPOSTDataKey:kScaleFactorKey];
    NSNumber * cw = [url numberForPOSTDataKey:kCreativeSafeWidthKey];
    NSNumber * ch = [url numberForPOSTDataKey:kCreativeSafeHeightKey];
    XCTAssert(cw.floatValue == 475.0 * sc.floatValue);
    XCTAssert(ch.floatValue == 250.0 * sc.floatValue);
}

#pragma mark - Impression Level Revenue Data

- (void)testImpressionNotificationWithImpressionData {
    XCTestExpectation * notificationExpectation = [self expectationWithDescription:@"Wait for impression notification"];
    NSString * testAdUnitId = @"FAKE_AD_UNIT_ID";

    // Make notification handler
    id notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMPImpressionTrackedNotification
                                                                                object:nil
                                                                                 queue:[NSOperationQueue mainQueue]
                                                                            usingBlock:^(NSNotification * note){
                                                                                [notificationExpectation fulfill];

                                                                                MPImpressionData * impressionData = note.userInfo[kMPImpressionTrackedInfoImpressionDataKey];
                                                                                XCTAssert([note.object isEqual:self.adView]);
                                                                                XCTAssertNotNil(impressionData);
                                                                                XCTAssert([self.adView.adUnitId isEqualToString:note.userInfo[kMPImpressionTrackedInfoAdUnitIDKey]]);
                                                                                XCTAssert([impressionData.adUnitID isEqualToString:testAdUnitId]);
                                                                            }];

    MPImpressionData * impressionData = [[MPImpressionData alloc] initWithDictionary:@{
                                                                                       kImpressionDataAdUnitIDKey: testAdUnitId
                                                                                       }];

    // Simulate impression
    [self.adView impressionDidFireWithImpressionData:impressionData];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
}

- (void)testImpressionNotificationWithNoImpressionData {
    XCTestExpectation * notificationExpectation = [self expectationWithDescription:@"Wait for impression notification"];

    // Make notification handler
    id notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMPImpressionTrackedNotification
                                                                                object:nil
                                                                                 queue:[NSOperationQueue mainQueue]
                                                                            usingBlock:^(NSNotification * note){
                                                                                [notificationExpectation fulfill];

                                                                                MPImpressionData * impressionData = note.userInfo[kMPImpressionTrackedInfoImpressionDataKey];
                                                                                XCTAssert([note.object isEqual:self.adView]);
                                                                                XCTAssertNil(impressionData);
                                                                                XCTAssert([self.adView.adUnitId isEqualToString:note.userInfo[kMPImpressionTrackedInfoAdUnitIDKey]]);
                                                                            }];

    // Simulate impression
    [self.adView impressionDidFireWithImpressionData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
}

@end
