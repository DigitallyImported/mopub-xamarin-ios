//
//  MPInterstitialAdControllerTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdServerKeys.h"
#import "MPAPIEndpoints.h"
#import "MPInterstitialAdController.h"
#import "MPInterstitialAdController+Testing.h"
#import "MPInterstitialAdManager+Testing.h"
#import "MPMockAdServerCommunicator.h"
#import "NSURLComponents+Testing.h"
#import "MPURL.h"
#import "MPImpressionTrackedNotification.h"

static NSTimeInterval const kTestTimeout = 0.5;

@interface MPInterstitialAdControllerTests : XCTestCase
@property (nonatomic, strong) MPInterstitialAdController * interstitial;
@property (nonatomic, weak) MPMockAdServerCommunicator * mockAdServerCommunicator;
@end

@implementation MPInterstitialAdControllerTests

- (void)setUp {
    [super setUp];
    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"FAKE_AD_UNIT_ID"];
    self.interstitial.manager.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.interstitial.manager];
        self.mockAdServerCommunicator = mock;
        mock;
    });
}

#pragma mark - Viewability

- (void)testViewabilityQueryParameter {
    // Interstitial ads should send a viewability query parameter.
    [self.interstitial loadAd];

    XCTAssertNotNil(self.mockAdServerCommunicator);
    XCTAssertNotNil(self.mockAdServerCommunicator.lastUrlLoaded);

    MPURL * url = [self.mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)self.mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);

    NSString * viewabilityValue = [url stringForPOSTDataKey:kViewabilityStatusKey];
    XCTAssertNotNil(viewabilityValue);
    XCTAssertTrue([viewabilityValue isEqualToString:@"1"]);
}

#pragma mark - Ad Sizing

- (void)testFullscreenCreativeSizeSent {
    [self.interstitial loadAd];

    XCTAssertNotNil(self.mockAdServerCommunicator);
    XCTAssertNotNil(self.mockAdServerCommunicator.lastUrlLoaded);

    MPURL * url = [self.mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)self.mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);

    NSNumber * sc = [url numberForPOSTDataKey:kScaleFactorKey];
    NSNumber * cw = [url numberForPOSTDataKey:kCreativeSafeWidthKey];
    NSNumber * ch = [url numberForPOSTDataKey:kCreativeSafeHeightKey];
    CGRect frame = MPApplicationFrame(YES);
    XCTAssert(cw.floatValue == frame.size.width * sc.floatValue);
    XCTAssert(ch.floatValue == frame.size.height * sc.floatValue);
}

# pragma mark - Impression Level Revenue Data

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
                                                                                XCTAssert([note.object isEqual:self.interstitial]);
                                                                                XCTAssertNotNil(impressionData);
                                                                                XCTAssert([self.interstitial.adUnitId isEqualToString:note.userInfo[kMPImpressionTrackedInfoAdUnitIDKey]]);
                                                                                XCTAssert([impressionData.adUnitID isEqualToString:testAdUnitId]);
                                                                            }];

    MPImpressionData * impressionData = [[MPImpressionData alloc] initWithDictionary:@{
                                                                                       kImpressionDataAdUnitIDKey: testAdUnitId
                                                                                       }];

    // Simulate impression
    [self.interstitial interstitialAdManager:nil didReceiveImpressionEventWithImpressionData:impressionData];

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
                                                                                XCTAssert([note.object isEqual:self.interstitial]);
                                                                                XCTAssert([self.interstitial.adUnitId isEqualToString:note.userInfo[kMPImpressionTrackedInfoAdUnitIDKey]]);
                                                                                XCTAssertNil(impressionData);
                                                                            }];

    // Simulate impression
    [self.interstitial interstitialAdManager:nil didReceiveImpressionEventWithImpressionData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
}

@end
