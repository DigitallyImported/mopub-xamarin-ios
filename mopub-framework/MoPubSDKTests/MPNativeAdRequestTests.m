//
//  MPNativeAdRequestTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfigurationFactory.h"
#import "MPAdServerKeys.h"
#import "MPAPIEndpoints.h"
#import "MPConstants.h"
#import "MPError.h"
#import "MPNativeAdRequest.h"
#import "MPNativeAdRequest+Testing.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPMockAdServerCommunicator.h"
#import "MPMockNativeCustomEvent.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPURL.h"
#import "NSURLComponents+Testing.h"
#import "MPNativeAdDelegateHandler.h"
#import "MPNativeAd+Testing.h"
#import "MPAdServerKeys.h"
#import "MPImpressionTrackedNotification.h"

static const NSTimeInterval kTestTimeout   = 2; // seconds

@interface MPNativeAdRequestTests : XCTestCase
@property (nonatomic, strong) NSArray * rendererConfigurations;
@end

@implementation MPNativeAdRequestTests

- (void)setUp {
    [super setUp];

    self.rendererConfigurations = ({
        // Generate renderer
        MPStaticNativeAdRendererSettings * settings = [[MPStaticNativeAdRendererSettings alloc] init];
        settings.renderingViewClass = [MPMockNativeCustomEventView class];
        settings.viewSizeHandler = ^(CGFloat maxWidth) { return CGSizeMake(70.0f, 113.0f); };

        MPNativeAdRendererConfiguration * rendererConfig = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
        NSMutableArray * supportedCustomEvents = [[NSMutableArray alloc] initWithArray:rendererConfig.supportedCustomEvents];
        [supportedCustomEvents addObject:@"MPMockNativeCustomEvent"];
        [supportedCustomEvents addObject:@"MPMockLongLoadNativeCustomEvent"];
        rendererConfig.supportedCustomEvents = supportedCustomEvents;

        @[rendererConfig];
    });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Networking

- (void)testEmptyConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for native load"];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:self.rendererConfigurations];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = @[];

    nativeAdRequest.communicator = communicator;
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error == nil) {
            XCTFail(@"Unexpected success");
        }
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 0);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 0);
}

- (void)testNilConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for native load"];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:self.rendererConfigurations];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = nil;

    nativeAdRequest.communicator = communicator;
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error == nil) {
            XCTFail(@"Unexpected success");
        }
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 0);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 0);
}

- (void)testMultipleResponsesFirstSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for native load"];

    // Generate the ad configurations
    MPAdConfiguration * nativeAdThatShouldLoad = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"MPMockNativeCustomEvent"];
    MPAdConfiguration * nativeAdLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"MPMockNativeCustomEvent"];
    MPAdConfiguration * nativeAdLoadFail = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[nativeAdThatShouldLoad, nativeAdLoadThatShouldNotLoad, nativeAdLoadFail];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:self.rendererConfigurations];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = configurations;

    nativeAdRequest.communicator = communicator;
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error != nil) {
            XCTFail(@"Unexpected failure");
        }
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 1);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 1);
}

- (void)testMultipleResponsesMiddleSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for native load"];

    // Generate the ad configurations
    MPAdConfiguration * nativeAdThatShouldLoad = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"MPMockNativeCustomEvent"];
    MPAdConfiguration * nativeAdLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"MPMockNativeCustomEvent"];
    MPAdConfiguration * nativeAdLoadFail = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[nativeAdLoadFail, nativeAdThatShouldLoad, nativeAdLoadThatShouldNotLoad];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:self.rendererConfigurations];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = configurations;

    nativeAdRequest.communicator = communicator;
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error != nil) {
            XCTFail(@"Unexpected failure");
        }
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
}

- (void)testMultipleResponsesLastSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for native load"];

    // Generate the ad configurations
    MPAdConfiguration * nativeAdThatShouldLoad = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"MPMockNativeCustomEvent"];
    MPAdConfiguration * nativeAdLoadFail1 = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * nativeAdLoadFail2 = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[nativeAdLoadFail1, nativeAdLoadFail2, nativeAdThatShouldLoad];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:self.rendererConfigurations];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = configurations;

    nativeAdRequest.communicator = communicator;
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error != nil) {
            XCTFail(@"Unexpected failure");
        }
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 3);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 3);
}

- (void)testMultipleResponsesFailOverToNextPage {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for native load"];

    // Generate the ad configurations
    MPAdConfiguration * nativeAdLoadFail1 = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * nativeAdLoadFail2 = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[nativeAdLoadFail1, nativeAdLoadFail2];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:self.rendererConfigurations];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = configurations;
    communicator.loadMockResponsesOnce = YES;

    nativeAdRequest.communicator = communicator;
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error == nil) {
            XCTFail(@"Unexpected success");
        }
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}

#pragma mark - Viewability

- (void)testViewabilityQueryParameterNotPresent {
    // Native ads should not send a viewability query parameter.
    MPMockAdServerCommunicator * mockAdServerCommunicator = nil;
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:nil];
    nativeAdRequest.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
        mockAdServerCommunicator = mock;
        mock;
    });
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        // The handler response doesn't matter.
    }];

    XCTAssertNotNil(mockAdServerCommunicator);
    XCTAssertNotNil(mockAdServerCommunicator.lastUrlLoaded);

    NSURL * url = mockAdServerCommunicator.lastUrlLoaded;
    NSURLComponents * urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];

    NSString * viewabilityQueryParamValue = [urlComponents valueForQueryParameter:@"vv"];
    XCTAssertNil(viewabilityQueryParamValue);
}

#pragma mark - Timeout

- (void)testTimeoutOverrideSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timeout"];

    // Generate the ad configurations
    MPAdConfiguration * config = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"MPMockNativeCustomEvent" additionalMetadata:@{kAdTimeoutMetadataKey: @(100), kNextUrlMetadataKey: @""}];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:self.rendererConfigurations];

    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = @[config];
    communicator.loadMockResponsesOnce = YES;

    nativeAdRequest.communicator = communicator;
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:NATIVE_TIMEOUT_INTERVAL handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify error was timeout
    XCTAssertTrue(communicator.lastAfterLoadResultWasTimeout);
}

- (void)testConsecutiveNativeAdRequestsDoNotTimeOut {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for first request timeout"];

    // Generate the ad configurations
    MPAdConfiguration * config = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"MPMockLongLoadNativeCustomEvent" additionalMetadata:@{kNextUrlMetadataKey: @""}];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:self.rendererConfigurations];

    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = @[config];
    communicator.loadMockResponsesOnce = YES;

    nativeAdRequest.communicator = communicator;
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:NATIVE_TIMEOUT_INTERVAL handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify no timeout for first request
    XCTAssertFalse(communicator.lastAfterLoadResultWasTimeout);

    // Set up for next ad request
    expectation = [self expectationWithDescription:@"Wait for second request timeout"];
    communicator.mockConfigurationsResponse = @[config];

    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:NATIVE_TIMEOUT_INTERVAL handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify no timeout for second request
    XCTAssertFalse(communicator.lastAfterLoadResultWasTimeout);
}

#pragma mark - Local Extras

- (void)testLocalExtrasInCustomEvent {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for native load"];

    // Generate the ad configurations
    MPAdConfiguration * nativeAdThatShouldLoad = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"MPMockNativeCustomEvent"];
    NSArray * configurations = @[nativeAdThatShouldLoad];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:self.rendererConfigurations];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = configurations;
    nativeAdRequest.communicator = communicator;

    MPNativeAdRequestTargeting * targeting = [MPNativeAdRequestTargeting targeting];
    targeting.localExtras = @{ @"testing": @"YES" };
    nativeAdRequest.targeting = targeting;

    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error != nil) {
            XCTFail(@"Unexpected failure");
        }

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    MPMockNativeCustomEvent * customEvent = (MPMockNativeCustomEvent *)nativeAdRequest.nativeCustomEvent;
    XCTAssertNotNil(customEvent);

    NSDictionary * localExtras = customEvent.localExtras;
    XCTAssertNotNil(localExtras);
    XCTAssert([localExtras[@"testing"] isEqualToString:@"YES"]);
    XCTAssertTrue(customEvent.isLocalExtrasAvailableAtRequest);
}

#pragma mark - Impression Level Revenue Data

- (void)testImpressionDelegateFiresWithoutILRD {
    XCTestExpectation * delegateExpectation = [self expectationWithDescription:@"Wait for impression delegate"];
    XCTestExpectation * notificationExpectation = [self expectationWithDescription:@"Wait for impression notification"];
    NSString * testAdUnitId = @"FAKE_AD_UNIT_ID";

    __block MPNativeAd * nativeAd = nil;

    // Make delegate handler
    MPNativeAdDelegateHandler * handler = [[MPNativeAdDelegateHandler alloc] init];
    handler.didTrackImpression = ^(MPNativeAd * ad, MPImpressionData * impressionData) {
        [delegateExpectation fulfill];

        XCTAssertNil(impressionData);
    };

    // Make notification handler
    id notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMPImpressionTrackedNotification
                                                                                object:nil
                                                                                 queue:[NSOperationQueue mainQueue]
                                                                            usingBlock:^(NSNotification * note){
                                                                                [notificationExpectation fulfill];

                                                                                XCTAssertNil(note.userInfo[kMPImpressionTrackedInfoImpressionDataKey]);
                                                                                XCTAssert([nativeAd isEqual:note.object]);
                                                                                XCTAssert([note.userInfo[kMPImpressionTrackedInfoAdUnitIDKey] isEqualToString:nativeAd.adUnitID]);
                                                                            }];

    // Generate the ad configurations
    MPAdConfiguration * nativeAdThatShouldLoad = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"MPMockNativeCustomEvent"];
    NSArray * configurations = @[nativeAdThatShouldLoad];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:testAdUnitId rendererConfigurations:self.rendererConfigurations];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = configurations;
    nativeAdRequest.communicator = communicator;

    nativeAdRequest.targeting = [MPNativeAdRequestTargeting targeting];
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error != nil) {
            XCTFail(@"Unexpected failure");
        }

        nativeAd = response;
        response.delegate = handler;
        [response trackImpression];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
}

- (void)testImpressionDelegateFiresWithILRD {
    XCTestExpectation * delegateExpectation = [self expectationWithDescription:@"Wait for impression delegate"];
    XCTestExpectation * notificationExpectation = [self expectationWithDescription:@"Wait for impression notification"];
    NSString * testAdUnitId = @"FAKE_AD_UNIT_ID";

    __block MPNativeAd * nativeAd = nil;

    // Make delegate handler
    MPNativeAdDelegateHandler * handler = [[MPNativeAdDelegateHandler alloc] init];
    handler.didTrackImpression = ^(MPNativeAd * ad, MPImpressionData * impressionData) {
        [delegateExpectation fulfill];

        XCTAssertNotNil(impressionData);
        XCTAssert([impressionData.adUnitID isEqualToString:testAdUnitId]);
    };

    // Make notification handler
    id notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMPImpressionTrackedNotification
                                                                                object:nil
                                                                                 queue:[NSOperationQueue mainQueue]
                                                                            usingBlock:^(NSNotification * note){
                                                                                [notificationExpectation fulfill];

                                                                                MPImpressionData * impressionData = note.userInfo[kMPImpressionTrackedInfoImpressionDataKey];
                                                                                XCTAssertNotNil(impressionData);
                                                                                XCTAssert([impressionData.adUnitID isEqualToString:testAdUnitId]);
                                                                                XCTAssert([nativeAd isEqual:note.object]);
                                                                                XCTAssert([note.userInfo[kMPImpressionTrackedInfoAdUnitIDKey] isEqualToString:nativeAd.adUnitID]);
                                                                            }];

    // Generate the ad configurations
    MPAdConfiguration * nativeAdThatShouldLoad = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"MPMockNativeCustomEvent"];
    nativeAdThatShouldLoad.impressionData = [[MPImpressionData alloc] initWithDictionary:@{
                                                                                           kImpressionDataAdUnitIDKey: testAdUnitId
                                                                                           }];
    NSArray * configurations = @[nativeAdThatShouldLoad];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:testAdUnitId rendererConfigurations:self.rendererConfigurations];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = configurations;
    nativeAdRequest.communicator = communicator;

    nativeAdRequest.targeting = [MPNativeAdRequestTargeting targeting];
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error != nil) {
            XCTFail(@"Unexpected failure");
        }

        nativeAd = response;
        response.delegate = handler;
        [response trackImpression];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
}

#pragma mark - Ad Sizing

- (void)testNativeCreativeSizeSentAsZero {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for native load"];

    // Generate ad request
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:self.rendererConfigurations];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
    communicator.mockConfigurationsResponse = @[];

    nativeAdRequest.communicator = communicator;
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error == nil) {
            XCTFail(@"Unexpected success");
        }
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 0);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 0);

    MPURL * url = [communicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)communicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);

    NSNumber * cw = [url numberForPOSTDataKey:kCreativeSafeWidthKey];
    NSNumber * ch = [url numberForPOSTDataKey:kCreativeSafeHeightKey];
    XCTAssert(cw.floatValue == 0.0);
    XCTAssert(ch.floatValue == 0.0);
}

@end
