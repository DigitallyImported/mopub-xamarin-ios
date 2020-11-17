//
//  MPAdServerCommunicatorTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdServerCommunicator.h"
#import "MPAdServerCommunicatorDelegateHandler.h"
#import "MPAdServerCommunicator+Testing.h"
#import "MPAdServerKeys.h"
#import "MPConsentManager+Testing.h"
#import "MPError.h"
#import "MPRateLimitManager.h"

static NSTimeInterval const kTimeoutTime = 0.5;
static NSUInteger const kDefaultRateLimitTimeMs = 400;
static NSString * const kDefaultRateLimitReason = @"Reason";

// Constants are from `MPAdServerCommunicator.m`
static NSString * const kAdResponsesKey = @"ad-responses";
static NSString * const kAdResonsesMetadataKey = @"metadata";
static NSString * const kAdResonsesContentKey = @"content";

static NSString * const kIsWhitelistedUserDefaultsKey = @"com.mopub.mopub-ios-sdk.is.whitelisted";

@interface MPAdServerCommunicatorTests : XCTestCase

@property (nonatomic, strong) MPAdServerCommunicator *communicator;
@property (nonatomic, strong) MPAdServerCommunicatorDelegateHandler *communicatorDelegateHandler;

@end

@implementation MPAdServerCommunicatorTests

- (void)setUp {
    [super setUp];

    [[MPConsentManager sharedManager] setUpConsentManagerForTesting];

    self.communicatorDelegateHandler = [[MPAdServerCommunicatorDelegateHandler alloc] init];
    self.communicator = [[MPAdServerCommunicator alloc] initWithDelegate:self.communicatorDelegateHandler];
    self.communicator.loading = YES;
}

- (void)tearDown {
    self.communicator = nil;
    self.communicatorDelegateHandler = nil;

    [super tearDown];
}

#pragma mark - JSON Flattening

- (void)testJSONFlattening {
    // The response data is a JSON payload conforming to the structure:
    // {
    //     "ad-responses": [
    //                      {
    //                          "metadata": {
    //                              "adm": "some advanced bidding payload",
    //                              "x-ad-timeout-ms": 5000,
    //                              "x-adtype": "rewarded_video",
    //                          },
    //                          "content": "Ad markup goes here"
    //                      }
    //                      ],
    //     "x-other-key": "some value",
    //     "x-next-url": "https:// ..."
    // }

    // Set up a valid response with three configurations
    NSDictionary * responseDataDict = @{
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },
                                               @{ kAdResonsesMetadataKey: @{ @"x-adtype": @"banner" }, kAdResonsesContentKey: @"mopub ad content" },
                                               @{ kAdResonsesMetadataKey: @{ @"x-adtype": @"banner" }, kAdResonsesContentKey: @"mopub ad content" },
                                               ],
                                       kNextUrlMetadataKey: @"https://www.mopub.com",
                                       @"testing_1": @"testing_1",
                                       @"testing_2": @"testing_2"
                                       };

    NSArray * topLevelJsonKeys = @[kNextUrlMetadataKey, @"testing_1", @"testing_2"];
    NSArray * responses = [self.communicator getFlattenJsonResponses:responseDataDict keys:topLevelJsonKeys];

    XCTAssertNotNil(responses);
    XCTAssert(responses.count == 3);

    for (NSDictionary * response in responses) {
        XCTAssertNotNil(response);

        NSDictionary * metadata = response[kAdResonsesMetadataKey];
        XCTAssertNotNil(metadata);

        XCTAssert([metadata[kNextUrlMetadataKey] isEqualToString:@"https://www.mopub.com"]);
        XCTAssert([metadata[@"testing_1"] isEqualToString:@"testing_1"]);
        XCTAssert([metadata[@"testing_2"] isEqualToString:@"testing_2"]);
    }
}

#pragma mark - Multiple Responses

- (void)testMultipleAdResponses {
    // The response data is a JSON payload conforming to the structure:
    // {
    //     "ad-responses": [
    //                      {
    //                          "metadata": {
    //                              "adm": "some advanced bidding payload",
    //                              "x-ad-timeout-ms": 5000,
    //                              "x-adtype": "rewarded_video",
    //                          },
    //                          "content": "Ad markup goes here"
    //                      }
    //                      ],
    //     "x-next-url": "https:// ..."
    // }

    // Set up a valid response with three configurations
    NSDictionary *responseDataDict = @{
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },
                                               @{ kAdResonsesMetadataKey: @{ @"x-adtype": @"banner" }, kAdResonsesContentKey: @"mopub ad content" },
                                               @{ kAdResonsesMetadataKey: @{ @"x-adtype": @"banner" }, kAdResonsesContentKey: @"mopub ad content" },
                                               ],
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 3 configurations
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 3);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testZeroAdResponses {
    // Set up a valid response with three configurations
    NSDictionary *responseDataDict = @{ kAdResponsesKey: @[] };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 0 configurations
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 0);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testMultipleAdResponsesWithNoMetadataField {
    // Set up an incorrect response with three configurations
    NSDictionary *responseDataDict = @{
                                       @"ad-responses":
                                           @[
                                               @{
                                                   @"headers": @{},
                                                   @"body": @"",
                                                   @"adm": @"",
                                               },
                                               @{
                                                   @"headers": @{},
                                                   @"body": @"",
                                               },
                                               @{
                                                   @"headers": @{},
                                                   @"body": @"",
                                                   @"adm": @"",
                                               },
                                           ],
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 0 configurations
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 0);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testMergingMetaData {
    // The response data is a JSON payload conforming to the structure:
    // {
    //     "ad-responses": [
    //                      {
    //                          "metadata": {
    //                              "adm": "some advanced bidding payload",
    //                              "x-ad-timeout-ms": 5000,
    //                              "x-adtype": "rewarded_video",
    //                          },
    //                          "content": "Ad markup goes here"
    //                      }
    //                      ],
    //     "x-next-url": "https:// ..."
    // }

    // Set up a valid response
    NSDictionary *responseDataDict = @{
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" }
                                               ],
                                       @"x-next-url": @"https://www.mopub.com/unittest"
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    MPAdConfiguration * config = adConfigurations.firstObject;
    XCTAssertNotNil(config);
    XCTAssert([config.nextURL.absoluteString isEqualToString:@"https://www.mopub.com/unittest"]);
}

- (void)testJSONParseError {
    // Set up response with broken JSON
    NSString *brokenJsonStringData = @"{\"ad-responses\":{{\"headers\":{},\"adm\":\"\",\"body\":\"\"},{\"headers\":{},\"body\":\"\"},{\"headers\":{},\"adm\":\"\",\"body\":\"\"}]}";
    NSData *responseData = [NSMutableData dataWithData:[brokenJsonStringData dataUsingEncoding:NSUTF8StringEncoding]];

    // Check for error delegate
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for error delegate to be called"];
    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError *error){
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertFalse(self.communicator.loading);
}

- (void)testNoDataResponsesError {
    // Set up response the old way
    NSData *responseData = [NSMutableData dataWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];

    // Check for one configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for error delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError *error) {
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNil(adConfigurations);
    XCTAssert(adConfigurations.count == 0);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testEmptyDataResponsesError {
    // Set up response with no ad-responses entry
    NSDictionary *responseDataDict = @{};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for error delegate
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for error delegate to be called"];
    __block NSInteger errorCode = -1;
    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError *error){
        errorCode = error.code;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssert(errorCode == MOPUBErrorUnableToParseJSONAdResponse);
    XCTAssertFalse(self.communicator.loading);
}

#pragma mark - Consent

- (void)testParseInvalidateConsent {
    // Initially set consent state to consented
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:kIsWhitelistedUserDefaultsKey];
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kInvalidateConsentKey: @"1",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has been invalidated back to unknown.
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusUnknown);
}

- (void)testParseReacquireConsent {
    // Initially set consent state to consented
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:kIsWhitelistedUserDefaultsKey];
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);
    XCTAssertFalse(MPConsentManager.sharedManager.isConsentNeeded);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kReacquireConsentKey: @"1",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has not changed, but needs to be reacquired
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);
    XCTAssertTrue(MPConsentManager.sharedManager.isConsentNeeded);
}

- (void)testParseForceExplicitNoConsent {
    // Initially set consent state to consented
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:kIsWhitelistedUserDefaultsKey];
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kForceExplicitNoKey: @"1",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has been forced to explicit no
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusDenied);
}

- (void)testParseForceGDPRApplies {
    // Initially set GDPR applicable state to not applicable
    [MPConsentManager.sharedManager setIsGDPRApplicable:MPBoolNo];
    XCTAssert(MPConsentManager.sharedManager.isGDPRApplicable == MPBoolNo);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kForceGDPRAppliesKey: @"1",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that GDPR applies
    XCTAssertTrue(MPConsentManager.sharedManager.isGDPRApplicable);
}

- (void)testConsentForceExplicitNoTakesPriorityOverInvalidateConsent {
    // Initially set consent state to consented
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:kIsWhitelistedUserDefaultsKey];
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kInvalidateConsentKey: @"1",
                                       kForceExplicitNoKey: @"1",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has been forced to explicit no
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusDenied);
}

- (void)testConsentForceExplicitNoDoesNothingWhenMalformed {
    // Initially set consent state to consented
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:kIsWhitelistedUserDefaultsKey];
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kForceExplicitNoKey: @"kjshgkjsrhgkwerhgq",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has not changed
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);
}

- (void)testConsentInvalidateConsentDoesNothingWhenMalformed {
    // Initially set consent state to consented
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:kIsWhitelistedUserDefaultsKey];
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kInvalidateConsentKey: @"kjshgkjsrhgkwerhgq",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has not changed
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);
}

- (void)testAutomaticAdUnitIdPopulation {
    // Garbage response data
    NSDictionary * responseDataDict = @{
                                         kAdResponsesKey: @[ @{
                                                                 kAdResonsesMetadataKey: @{
                                                                         @"x-adtype": @"clear",
                                                                         @"x-backfill": @"clear",
                                                                         @"x-refreshtime": @(30),
                                                                         },
                                                                 kAdResonsesContentKey: @""
                                                                 }, ]
                                         };
    NSData * garbageResponseData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                        options:0
                                                          error:nil];

    MPConsentManager * manager = MPConsentManager.sharedManager;
    // Clear out any cached adunit state
    [manager setUpConsentManagerForTesting];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    // Simulate a successful ad load
    NSString * adunitID = @"extremely not an actual adunit ID";

    self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator = ^NSString *(MPAdServerCommunicator *adServerCommunicator) {
        return adunitID;
    };

    [self.communicator didFinishLoadingWithData:garbageResponseData];

    // Check to make sure the adunit ID populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure the adunit ID is cached
    NSString * cachedString = [NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey];
    XCTAssert([cachedString isEqualToString:adunitID]);
}

- (void)testAutomaticAdUnitIdPopulationDoesNotOverwrite {
    // Garbage response data
    NSDictionary * responseDataDict = @{
                                        kAdResponsesKey: @[ @{
                                                                kAdResonsesMetadataKey: @{
                                                                        @"x-adtype": @"clear",
                                                                        @"x-backfill": @"clear",
                                                                        @"x-refreshtime": @(30),
                                                                        },
                                                                kAdResonsesContentKey: @""
                                                                }, ]
                                        };
    NSData * garbageResponseData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                                   options:0
                                                                     error:nil];

    MPConsentManager * manager = MPConsentManager.sharedManager;
    // Clear out any cached adunit state
    [manager setUpConsentManagerForTesting];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    // Simulate a successful ad load
    NSString * adunitID = @"extremely not an actual adunit ID";

    self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator = ^NSString *(MPAdServerCommunicator *adServerCommunicator) {
        return adunitID;
    };

    [self.communicator didFinishLoadingWithData:garbageResponseData];

    // Check to make sure the adunit ID populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure the adunit ID is cached
    NSString * cachedString = [NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey];
    XCTAssert([cachedString isEqualToString:adunitID]);


    // Make a new adunit ID and see if that gets set
    NSString * newAdunitID = @"still not an adunit ID";
    self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator = ^NSString *(MPAdServerCommunicator *adServerCommunicator) {
        return newAdunitID;
    };
    [self.communicator didFinishLoadingWithData:garbageResponseData];

    // Check state
    XCTAssertFalse([manager.adUnitIdUsedForConsent isEqualToString:newAdunitID]);
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    XCTAssert([cachedString isEqualToString:adunitID]);
}

- (void)testAutomaticAdUnitIDPopulationDoesNotOccurOnFailure {
    MPConsentManager * manager = MPConsentManager.sharedManager;
    // Clear out any cached adunit state
    [manager setUpConsentManagerForTesting];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    // Simulate an unsuccessful ad load
    NSString * adunitID = @"extremely not an actual adunit ID";
    self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator = ^NSString *(MPAdServerCommunicator *adServerCommunicator) {
        return adunitID;
    };
    [self.communicator didFailWithError:nil];

    // Check to make sure the adunit ID is not populated
    XCTAssertNil(manager.adUnitIdUsedForConsent);
    // Check to make sure the adunit ID is cached
    NSString * cachedString = [NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey];
    XCTAssertNil(cachedString);
}

#pragma mark - Rate Limiting Tests

- (void)testRateLimitTimerSuccessfullySetOnClearResponseWithBackoffKeyWithoutReason {
    NSDictionary *  responseDataDict = @{
                                         kBackoffMsKey: @(kDefaultRateLimitTimeMs),
                                         kAdResponsesKey: @[ @{
                                                   kAdResonsesMetadataKey: @{
                                                          @"x-adtype": @"clear",
                                                          @"x-backfill": @"clear",
                                                          @"x-refreshtime": @(30),
                                                          },
                                                   kAdResonsesContentKey: @""
                                                   }, ]
                                         };
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                        options:0
                                                          error:nil];

    XCTestExpectation * waitForRateLimit = [self expectationWithDescription:@"Wait for rate limit to end"];
    XCTestExpectation * waitForDelegate = [self expectationWithDescription:@"Wait for failure delegate"];

    __block BOOL didFail = NO;
    __block NSError * didFailError = nil;

    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError * error){
        didFail = YES;
        didFailError = error;

        [waitForDelegate fulfill];
    };

    self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator = ^(MPAdServerCommunicator * communicator){
        return @"testRateLimitTimerSuccessfullySetOnClearResponseWithBackoffKeyWithoutReason";
    };

    // Load data (set rate limit timer)
    [self.communicator didFinishLoadingWithData:jsonData];

    // Attempt URL request (see if rate limit timer blocks it)
    [self.communicator loadURL:[NSURL URLWithString:@"https://google.com"]];

    BOOL isRateLimited = self.communicator.isRateLimited;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDefaultRateLimitTimeMs * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [waitForRateLimit fulfill];

        // Did the rate limit timer get set
        XCTAssertTrue(isRateLimited);
        XCTAssertEqual(kDefaultRateLimitTimeMs, [[MPRateLimitManager sharedInstance] lastRateLimitMillisecondsForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]);
        XCTAssertNil([[MPRateLimitManager sharedInstance] lastRateLimitReasonForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]);

        // Did the attempt at a request fail
        XCTAssertTrue(didFail);
        XCTAssertEqual(didFailError.code, MOPUBErrorTooManyRequests);
    });

    [self waitForExpectations:@[waitForRateLimit, waitForDelegate] timeout:kTimeoutTime];
}

- (void)testRateLimitTimerSuccessfullySetOnClearResponseWithBackoffKeyWithReason {
    NSDictionary *  responseDataDict = @{
                                         kBackoffMsKey: @(kDefaultRateLimitTimeMs),
                                         kBackoffReasonKey: kDefaultRateLimitReason,
                                         kAdResponsesKey: @[ @{
                                                                 kAdResonsesMetadataKey: @{
                                                                         @"x-adtype": @"clear",
                                                                         @"x-backfill": @"clear",
                                                                         @"x-refreshtime": @(30),
                                                                         },
                                                                 kAdResonsesContentKey: @""
                                                                 }, ]
                                         };
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                        options:0
                                                          error:nil];

    XCTestExpectation * waitForRateLimit = [self expectationWithDescription:@"Wait for rate limit to end"];
    XCTestExpectation * waitForDelegate = [self expectationWithDescription:@"Wait for failure delegate"];

    __block BOOL didFail = NO;
    __block NSError * didFailError = nil;

    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError * error){
        didFail = YES;
        didFailError = error;

        [waitForDelegate fulfill];
    };

    self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator = ^(MPAdServerCommunicator * communicator){
        return @"testRateLimitTimerSuccessfullySetOnClearResponseWithBackoffKeyWithReason";
    };

    // Load data (set rate limit timer)
    [self.communicator didFinishLoadingWithData:jsonData];

    // Attempt URL request (see if rate limit timer blocks it)
    [self.communicator loadURL:[NSURL URLWithString:@"https://google.com"]];

    BOOL isRateLimited = self.communicator.isRateLimited;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDefaultRateLimitTimeMs * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [waitForRateLimit fulfill];

        // Did the rate limit timer get set
        XCTAssertTrue(isRateLimited);
        XCTAssertEqual(kDefaultRateLimitTimeMs, [[MPRateLimitManager sharedInstance] lastRateLimitMillisecondsForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]);
        XCTAssert([kDefaultRateLimitReason isEqualToString:[[MPRateLimitManager sharedInstance] lastRateLimitReasonForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]]);

        // Did the attempt at a request fail
        XCTAssertTrue(didFail);
        XCTAssertEqual(didFailError.code, MOPUBErrorTooManyRequests);
    });

    [self waitForExpectations:@[waitForRateLimit, waitForDelegate] timeout:kTimeoutTime];
}

- (void)testRateLimitTimerIsNotSetOnClearResponseWithNoBackoffKey {
    NSDictionary *responseDataDict = @{
                                       kAdResponsesKey: @[ @{
                                                               kAdResonsesMetadataKey: @{
                                                                       @"x-adtype": @"clear",
                                                                       @"x-backfill": @"clear",
                                                                       @"x-refreshtime": @(30),
                                                                       },
                                                               kAdResonsesContentKey: @""
                                                               }, ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];

    self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator = ^(MPAdServerCommunicator * communicator){
        return @"testRateLimitTimerIsNotSetOnClearResponseWithNoBackoffKey";
    };

    [self.communicator didFinishLoadingWithData:jsonData];

    XCTAssertFalse(self.communicator.isRateLimited);
    XCTAssertEqual(0, [[MPRateLimitManager sharedInstance] lastRateLimitMillisecondsForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]);
    XCTAssertNil([[MPRateLimitManager sharedInstance] lastRateLimitReasonForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]);
}

- (void)testRateLimitTimerIsSetOnMraidResponseWithReason {
    NSDictionary *responseDataDict = @{
                                       kBackoffMsKey: @(kDefaultRateLimitTimeMs),
                                       kBackoffReasonKey: kDefaultRateLimitReason,
                                       kAdResponsesKey: @[ @{
                                                               kAdResonsesMetadataKey: @{
                                                                       @"x-adtype": @"mraid",
                                                                       },
                                                               kAdResonsesContentKey: @""
                                                               }, ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];

    XCTestExpectation * waitForRateLimit = [self expectationWithDescription:@"Wait for rate limit to end"];
    XCTestExpectation * waitForDelegate = [self expectationWithDescription:@"Wait for failure delegate"];

    __block BOOL didFail = NO;
    __block NSError * didFailError = nil;

    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError * error){
        didFail = YES;
        didFailError = error;

        [waitForDelegate fulfill];
    };

    self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator = ^(MPAdServerCommunicator * communicator){
        return @"testRateLimitTimerIsSetOnMraidResponseWithReason";
    };

    // Load data (set rate limit timer)
    [self.communicator didFinishLoadingWithData:jsonData];

    // Attempt URL request (see if rate limit timer blocks it)
    [self.communicator loadURL:[NSURL URLWithString:@"https://google.com"]];

    BOOL isRateLimited = self.communicator.isRateLimited;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDefaultRateLimitTimeMs * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [waitForRateLimit fulfill];

        // Did the rate limit timer get set
        XCTAssertTrue(isRateLimited);
        XCTAssertEqual(kDefaultRateLimitTimeMs, [[MPRateLimitManager sharedInstance] lastRateLimitMillisecondsForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]);
        XCTAssert([kDefaultRateLimitReason isEqualToString:[[MPRateLimitManager sharedInstance] lastRateLimitReasonForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]]);

        // Did the attempt at a request fail
        XCTAssertTrue(didFail);
        XCTAssertEqual(didFailError.code, MOPUBErrorTooManyRequests);
    });

    [self waitForExpectations:@[waitForRateLimit, waitForDelegate] timeout:kTimeoutTime];
}

- (void)testRateLimitTimerIsSetOnMraidResponseWithoutReason {
    NSDictionary *responseDataDict = @{
                                       kBackoffMsKey: @(kDefaultRateLimitTimeMs),
                                       kAdResponsesKey: @[ @{
                                                               kAdResonsesMetadataKey: @{
                                                                       @"x-adtype": @"mraid",
                                                                       },
                                                               kAdResonsesContentKey: @""
                                                               }, ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];

    XCTestExpectation * waitForRateLimit = [self expectationWithDescription:@"Wait for rate limit to end"];
    XCTestExpectation * waitForDelegate = [self expectationWithDescription:@"Wait for failure delegate"];

    __block BOOL didFail = NO;
    __block NSError * didFailError = nil;

    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError * error){
        didFail = YES;
        didFailError = error;

        [waitForDelegate fulfill];
    };

    self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator = ^(MPAdServerCommunicator * communicator){
        return @"testRateLimitTimerIsSetOnMraidResponseWithoutReason";
    };

    // Load data (set rate limit timer)
    [self.communicator didFinishLoadingWithData:jsonData];

    // Attempt URL request (see if rate limit timer blocks it)
    [self.communicator loadURL:[NSURL URLWithString:@"https://google.com"]];

    BOOL isRateLimited = self.communicator.isRateLimited;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDefaultRateLimitTimeMs * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [waitForRateLimit fulfill];

        // Did the rate limit timer get set
        XCTAssertTrue(isRateLimited);
        XCTAssertEqual(kDefaultRateLimitTimeMs, [[MPRateLimitManager sharedInstance] lastRateLimitMillisecondsForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]);
        XCTAssertNil([[MPRateLimitManager sharedInstance] lastRateLimitReasonForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]);

        // Did the attempt at a request fail
        XCTAssertTrue(didFail);
        XCTAssertEqual(didFailError.code, MOPUBErrorTooManyRequests);
    });

    [self waitForExpectations:@[waitForRateLimit, waitForDelegate] timeout:kTimeoutTime];
}

- (void)testRateLimitTimerIsNotSetOnMraidResponseWithNoBackoffKey {
    NSDictionary *responseDataDict = @{
                                       kAdResponsesKey: @[ @{
                                                               kAdResonsesMetadataKey: @{
                                                                       @"x-adtype": @"mraid",
                                                                       },
                                                               kAdResonsesContentKey: @""
                                                               }, ]
                                       };

    self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator = ^(MPAdServerCommunicator * communicator){
        return @"testRateLimitTimerIsNotSetOnMraidResponseWithNoBackoffKey";
    };

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];

    [self.communicator didFinishLoadingWithData:jsonData];

    XCTAssertFalse(self.communicator.isRateLimited);
    XCTAssertEqual(0, [[MPRateLimitManager sharedInstance] lastRateLimitMillisecondsForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]);
    XCTAssertNil([[MPRateLimitManager sharedInstance] lastRateLimitReasonForAdUnitId:self.communicatorDelegateHandler.adUnitIdForAdServerCommunicator(nil)]);
}

@end
