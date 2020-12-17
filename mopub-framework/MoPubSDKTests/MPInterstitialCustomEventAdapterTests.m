//
//  MPInterstitialCustomEventAdapterTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfigurationFactory.h"
#import "MPConstants.h"
#import "MPConstants+Testing.h"
#import "MPError.h"
#import "MPInterstitialCustomEventAdapter.h"
#import "MPInterstitialAdapterDelegateHandler.h"
#import "MPInterstitialCustomEventAdapter+Testing.h"
#import "MPInterstitialCustomEvent.h"
#import "MPHTMLInterstitialCustomEvent.h"
#import "MPMRAIDInterstitialCustomEvent.h"

static NSTimeInterval const kTestTimeout = 2;

@interface MPInterstitialCustomEventAdapterTests : XCTestCase

@property (nonatomic, strong) MPInterstitialCustomEventAdapter *adapter;
@property (nonatomic, strong) MPInterstitialAdapterDelegateHandler *delegateHandler;

@end

@implementation MPInterstitialCustomEventAdapterTests

- (void)setUp {
    [super setUp];

    self.delegateHandler = [[MPInterstitialAdapterDelegateHandler alloc] init];
    self.adapter = [[MPInterstitialCustomEventAdapter alloc] initWithDelegate:self.delegateHandler];
}

// be sure `trackImpression` marks `hasTrackedImpression` as `YES`
- (void)testTrackImpressionSetsHasTrackedImpressionCorrectly {
    XCTAssertFalse(self.adapter.hasTrackedImpression);
    [self.adapter trackImpression];
    XCTAssertTrue(self.adapter.hasTrackedImpression);
}

// test that ad expires if no impression is tracked within the given limit, and be sure the callback is called
- (void)testAdWillExpireWithNoImpressionHTML {
    MPHTMLInterstitialCustomEvent *customEvent = [[MPHTMLInterstitialCustomEvent alloc] init];

    [self adWillExpireWithNoImpression:customEvent];
}

- (void)testAdWillExpireWithNoImpressionMRAID {
    MPMRAIDInterstitialCustomEvent *customEvent = [[MPMRAIDInterstitialCustomEvent alloc] init];

    [self adWillExpireWithNoImpression:customEvent];
}

- (void)adWillExpireWithNoImpression:(MPInterstitialCustomEvent *)customEvent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for expiration delegate method to be triggered"];

    __block BOOL didExpire = NO;
    self.delegateHandler.didExpire = ^(MPBaseInterstitialAdapter *adapter) {
        didExpire = YES;
        [expectation fulfill];
    };

    [self.adapter interstitialCustomEvent:customEvent didLoadAd:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(didExpire);
    XCTAssertFalse(self.adapter.hasTrackedImpression);
}

// test ad does not expire if impression is tracked
- (void)testAdWillNotExpireIfImpressionIsTrackedHTML {
    MPHTMLInterstitialCustomEvent *customEvent = [[MPHTMLInterstitialCustomEvent alloc] init];

    [self adWillNotExpireIfImpressionIsTracked:customEvent];
}

- (void)testAdWillNotExpireIfImpressionIsTrackedMRAID {
    MPMRAIDInterstitialCustomEvent *customEvent = [[MPMRAIDInterstitialCustomEvent alloc] init];

    [self adWillNotExpireIfImpressionIsTracked:customEvent];
}

- (void)adWillNotExpireIfImpressionIsTracked:(MPInterstitialCustomEvent *)customEvent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for expiration interval to elapse"];

    __block BOOL didExpire = NO;
    self.delegateHandler.didExpire = ^(MPBaseInterstitialAdapter *adapter) {
        didExpire = YES;
    };

    [self.adapter interstitialCustomEvent:customEvent didLoadAd:nil];
    [self.adapter trackImpression];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([MPConstants adsExpirationInterval] + 0.5) * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       [expectation fulfill];
                   });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(self.adapter.hasTrackedImpression);
    XCTAssertFalse(didExpire);
}

// test ad never expires if not mopub-specific custom event
- (void)testAdNeverExpiresIfNotMoPubCustomEvent {
    MPInterstitialCustomEvent *customEvent = [[MPInterstitialCustomEvent alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for expiration interval to elapse"];

    __block BOOL didExpire = NO;
    self.delegateHandler.didExpire = ^(MPBaseInterstitialAdapter *adapter) {
        didExpire = YES;
    };

    [self.adapter interstitialCustomEvent:customEvent didLoadAd:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([MPConstants adsExpirationInterval] + 0.5) * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       [expectation fulfill];
                   });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(self.adapter.hasTrackedImpression);
    XCTAssertFalse(didExpire);
}

#pragma mark - Timeout

- (void)testTimeoutOverrideSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timeout"];

    // Generate the ad configurations
    MPAdConfiguration * config = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"MPMockInterstitialCustomEvent" additionalMetadata:@{kAdTimeoutMetadataKey: @(1000)}];

    // Configure handler
    __block BOOL didTimeout = NO;
    MPInterstitialAdapterDelegateHandler * handler = MPInterstitialAdapterDelegateHandler.new;
    handler.didFailToLoadAd = ^(MPBaseInterstitialAdapter * adapter, NSError * error) {
        if (error != nil && error.code == MOPUBErrorAdRequestTimedOut) {
            didTimeout = YES;
        }

        [expectation fulfill];
    };

    // Adapter contains the timeout logic
    MPInterstitialCustomEventAdapter * adapter = [MPInterstitialCustomEventAdapter new];
    adapter.configuration = config;
    adapter.delegate = handler;
    [adapter startTimeoutTimer];

    [self waitForExpectationsWithTimeout:INTERSTITIAL_TIMEOUT_INTERVAL handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify error was timeout
    XCTAssertTrue(didTimeout);
}

@end
