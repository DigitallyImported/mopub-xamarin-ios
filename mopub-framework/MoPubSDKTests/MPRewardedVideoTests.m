//
//  MPRewardedVideoTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPAdServerKeys.h"
#import "MoPub.h"
#import "MPMockAdServerCommunicator.h"
#import "MPRewardedVideo.h"
#import "MPRewardedVideo+Testing.h"
#import "MPRewardedVideoAdapter+Testing.h"
#import "MPRewardedVideoDelegateHandler.h"
#import "MPStubCustomEvent.h"
#import "MPURL.h"
#import "NSURLComponents+Testing.h"

static NSString * const kTestAdUnitId    = @"967f82c7-c059-4ae8-8cb6-41c34265b1ef";
static const NSTimeInterval kTestTimeout = 2; // seconds

@interface MPRewardedVideoTests : XCTestCase
@end

@implementation MPRewardedVideoTests

- (void)setUp {
    [super setUp];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:kTestAdUnitId];
        config.additionalNetworks = nil;
        config.globalMediationSettings = nil;
        [MoPub.sharedInstance initializeSdkWithConfiguration:config completion:nil];
    });
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Delegates

- (void)testRewardedSuccessfulDelegateSetUnset {
    // Fake ad unit ID
    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];

    // Set the delegate handler
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];

    id<MPRewardedVideoDelegate> handler = [MPRewardedVideo.sharedInstance.delegateTable objectForKey:adUnitId];
    XCTAssertNotNil(handler);
    XCTAssert(handler == delegateHandler);

    // Unset the delegate handler
    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
    handler = [MPRewardedVideo.sharedInstance.delegateTable objectForKey:adUnitId];
    XCTAssertNil(handler);
}

- (void)testRewardedSuccessfulDelegateSetUnsetMultiple {
    // Fake ad unit ID
    NSString * adUnitId1 = [NSString stringWithFormat:@"%@:%s_1", kTestAdUnitId, __FUNCTION__];
    NSString * adUnitId2 = [NSString stringWithFormat:@"%@:%s_2", kTestAdUnitId, __FUNCTION__];

    // Set the delegate handler
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId1];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId2];

    id<MPRewardedVideoDelegate> handler1 = [MPRewardedVideo.sharedInstance.delegateTable objectForKey:adUnitId1];
    XCTAssertNotNil(handler1);
    XCTAssert(handler1 == delegateHandler);

    id<MPRewardedVideoDelegate> handler2 = [MPRewardedVideo.sharedInstance.delegateTable objectForKey:adUnitId2];
    XCTAssertNotNil(handler2);
    XCTAssert(handler2 == delegateHandler);

    // Unset the delegate handler
    [MPRewardedVideo removeDelegate:delegateHandler];
    handler1 = [MPRewardedVideo.sharedInstance.delegateTable objectForKey:adUnitId1];
    XCTAssertNil(handler1);

    handler2 = [MPRewardedVideo.sharedInstance.delegateTable objectForKey:adUnitId2];
    XCTAssertNil(handler2);
}

- (void)testRewardedSuccessfulDelegateSetAutoNil {
    // Fake ad unit ID
    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];

    // Use autorelease pool to force memory cleanup
    @autoreleasepool {
        // Set the delegate handler
        MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
        [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];

        id<MPRewardedVideoDelegate> handler = [MPRewardedVideo.sharedInstance.delegateTable objectForKey:adUnitId];
        XCTAssertNotNil(handler);
        XCTAssert(handler == delegateHandler);

        delegateHandler = nil;
    }

    // Verify no handler
    id<MPRewardedVideoDelegate> handler = [MPRewardedVideo.sharedInstance.delegateTable objectForKey:adUnitId];
    XCTAssertNil(handler);
}

- (void)testRewardedSetNilDelegate {
    // Fake ad unit ID
    NSString * adUnitId = nil;

    // Set the delegate handler
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];

    id<MPRewardedVideoDelegate> handler = [MPRewardedVideo.sharedInstance.delegateTable objectForKey:adUnitId];
    XCTAssertNil(handler);
}

- (void)testRewardedSetNilDelegateHandler {
    // Fake ad unit ID
    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];

    // Set the delegate handler
    MPRewardedVideoDelegateHandler * delegateHandler = nil;
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];

    id<MPRewardedVideoDelegate> handler = [MPRewardedVideo.sharedInstance.delegateTable objectForKey:adUnitId];
    XCTAssertNil(handler);
}

#pragma mark - Single Currency

- (void)testRewardedSingleCurrencyPresentationSuccess {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];

    MPRewardedVideoReward * singleReward = ({
        NSArray<MPRewardedVideoReward *> * rewards = [MPRewardedVideo availableRewardsForAdUnitID:adUnitId];
        rewards.firstObject;
    });
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:singleReward];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssert([rewardForUser.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(rewardForUser.amount.integerValue == 3);

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
}

- (void)testRewardedSingleItemInMultiCurrencyPresentationSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];

    MPRewardedVideoReward * singleReward = ({
        NSArray<MPRewardedVideoReward *> * rewards = [MPRewardedVideo availableRewardsForAdUnitID:adUnitId];
        rewards.firstObject;
    });
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:singleReward];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssert([rewardForUser.currencyType isEqualToString:@"Coins"]);
    XCTAssert(rewardForUser.amount.integerValue == 8);

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
}

- (void)testRewardedSingleItemInMultiCurrencyPresentationS2SSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedVideoCompletionUrlMetadataKey: @"https://test.com?verifier=123",
                                kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) } ] }
                              };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
    };

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];

    MPRewardedVideoReward * singleReward = ({
        NSArray<MPRewardedVideoReward *> * rewards = [MPRewardedVideo availableRewardsForAdUnitID:adUnitId];
        rewards.firstObject;
    });
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:singleReward];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssertNotNil(s2sUrl);

    MPURL * s2sMoPubUrl = [s2sUrl isKindOfClass:[MPURL class]] ? (MPURL *)s2sUrl : nil;
    XCTAssertNotNil(s2sMoPubUrl);
    XCTAssert([[s2sMoPubUrl stringForPOSTDataKey:kRewardedCurrencyNameKey] isEqualToString:@"Coins"]);
    XCTAssert([[s2sMoPubUrl stringForPOSTDataKey:kRewardedCurrencyAmountKey] isEqualToString:@"8"]);

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
}

#pragma mark - Multiple Currency

- (void)testRewardedMultiCurrencyPresentationSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    NSArray * availableRewards = [MPRewardedVideo availableRewardsForAdUnitID:adUnitId];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:availableRewards[1]];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssert([rewardForUser.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(rewardForUser.amount.integerValue == 1);

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
}

- (void)testRewardedMultiCurrencyPresentationNilParameterAutoSelectionFailure {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    __block BOOL didFail = NO;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        didFail = NO;
        [expectation fulfill];
    };

    delegateHandler.didFailToPlayAd = ^() {
        rewardForUser = nil;
        didFail = YES;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(rewardForUser);
    XCTAssertTrue(didFail);

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
}

- (void)testRewardedMultiCurrencyPresentationUnknownSelectionFail {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    __block BOOL didFail = NO;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        didFail = NO;
        [expectation fulfill];
    };

    delegateHandler.didFailToPlayAd = ^() {
        rewardForUser = nil;
        didFail = YES;
        [expectation fulfill];
    };

    // Create a malicious reward
    MPRewardedVideoReward * badReward = [[MPRewardedVideoReward alloc] initWithCurrencyType:@"$$$" amount:@(100)];

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:badReward];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(rewardForUser);
    XCTAssertTrue(didFail);

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
}

- (void)testRewardedMultiCurrencyS2SPresentationSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedVideoCompletionUrlMetadataKey: @"https://test.com?verifier=123",
                                kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] }
                              };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
    };

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    NSArray * availableRewards = [MPRewardedVideo availableRewardsForAdUnitID:adUnitId];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:availableRewards[1]];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssertNotNil(s2sUrl);

    MPURL * s2sMoPubUrl = [s2sUrl isKindOfClass:[MPURL class]] ? (MPURL *)s2sUrl : nil;
    XCTAssertNotNil(s2sMoPubUrl);
    XCTAssert([[s2sMoPubUrl stringForPOSTDataKey:kRewardedCurrencyNameKey] isEqualToString:@"Diamonds"]);
    XCTAssert([[s2sMoPubUrl stringForPOSTDataKey:kRewardedCurrencyAmountKey] isEqualToString:@"1"]);

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
}

- (void)testRewardedS2SNoRewardSpecified {
    NSDictionary * headers = @{ kRewardedVideoCompletionUrlMetadataKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
    };

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    NSArray * availableRewards = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:availableRewards[0]];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssertNotNil(s2sUrl);

    NSURLComponents * s2sUrlComponents = [NSURLComponents componentsWithURL:s2sUrl resolvingAgainstBaseURL:NO];
    XCTAssertFalse([s2sUrlComponents hasQueryParameter:@"rcn"]);
    XCTAssertFalse([s2sUrlComponents valueForQueryParameter:@"rca"]);

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
}

#pragma mark - Custom Data

- (void)testCustomDataNormalDataLength {
    // Generate a custom data string that is well under 8196 characters
    NSString * customData = [@"" stringByPaddingToLength:512 withString:@"test" startingAtIndex:0];

    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                kRewardedVideoCompletionUrlMetadataKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:reward customData:customData];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);

    MPURL * s2sMoPubUrl = [s2sUrl isKindOfClass:[MPURL class]] ? (MPURL *)s2sUrl : nil;
    XCTAssertNotNil(s2sMoPubUrl);
    XCTAssert([[s2sMoPubUrl stringForPOSTDataKey:kRewardedCustomDataKey] isEqualToString:customData]);
}

- (void)testCustomDataExcessiveDataLength {
    // Generate a custom data string that exceeds 8196 characters
    NSString * customData = [@"" stringByPaddingToLength:8200 withString:@"test" startingAtIndex:0];

    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                kRewardedVideoCompletionUrlMetadataKey: @"https://test.com?verifier=123",
                              };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:reward customData:customData];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);

    MPURL * s2sMoPubUrl = [s2sUrl isKindOfClass:[MPURL class]] ? (MPURL *)s2sUrl : nil;
    XCTAssertNotNil(s2sMoPubUrl);
    XCTAssert([[s2sMoPubUrl stringForPOSTDataKey:kRewardedCustomDataKey] isEqualToString:customData]);

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
}

- (void)testCustomDataNil {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                kRewardedVideoCompletionUrlMetadataKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:reward customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);
    XCTAssert(![s2sUrl.absoluteString containsString:@"rcd="]);
}

- (void)testCustomDataEmpty {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                kRewardedVideoCompletionUrlMetadataKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:reward customData:@""];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);
    XCTAssert(![s2sUrl.absoluteString containsString:@"rcd="]);
}

- (void)testCustomDataInPOSTData {
    // Custom data in need of URI encoding
    NSString * customData = @"{ \"key\": \"some value with spaces\" }";

    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                kRewardedVideoCompletionUrlMetadataKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:reward customData:customData];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);

    MPURL * s2sMoPubUrl = [s2sUrl isKindOfClass:[MPURL class]] ? (MPURL *)s2sUrl : nil;
    XCTAssertNotNil(s2sMoPubUrl);
    XCTAssert([[s2sMoPubUrl stringForPOSTDataKey:kRewardedCustomDataKey] isEqualToString:customData]);
}

- (void)testCustomDataLocalReward {
    // Generate a custom data string that is well under 8196 characters
    NSString * customData = [@"" stringByPaddingToLength:512 withString:@"test" startingAtIndex:0];

    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
    };

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];

    MPRewardedVideoAdManager * manager = [MPRewardedVideo adManagerForAdUnitId:adUnitId];
    MPRewardedVideoAdapter * adapter = manager.adapter;

    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:reward customData:customData];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(s2sUrl);
    XCTAssertNotNil(adapter);
    XCTAssertNil(adapter.customData);

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];
}

- (void)testNetworkIdentifierInRewardCallback {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kCustomEventClassNameMetadataKey: @"MPMockChartboostRewardedVideoCustomEvent",
                                kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                kRewardedVideoCompletionUrlMetadataKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:reward customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);

    MPURL * s2sMoPubUrl = [s2sUrl isKindOfClass:[MPURL class]] ? (MPURL *)s2sUrl : nil;
    XCTAssertNotNil(s2sMoPubUrl);
    XCTAssert([[s2sMoPubUrl stringForPOSTDataKey:kRewardedCustomEventNameKey] isEqualToString:@"MPMockChartboostRewardedVideoCustomEvent"]);
}

- (void)testMoPubNetworkIdentifierInRewardCallback {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kAdTypeMetadataKey: @"rewarded_video",
                                kCustomEventClassNameMetadataKey: @"rewarded_video",
                                kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                kRewardedVideoCompletionUrlMetadataKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:[UIViewController new] withReward:reward customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);

    MPURL * s2sMoPubUrl = [s2sUrl isKindOfClass:[MPURL class]] ? (MPURL *)s2sUrl : nil;
    XCTAssertNotNil(s2sMoPubUrl);
    XCTAssert([[s2sMoPubUrl stringForPOSTDataKey:kRewardedCustomEventNameKey] isEqualToString:@"MPMoPubRewardedVideoCustomEvent"]);
}

#pragma mark - Ad Sizing

- (void)testRewardedCreativeSizeSent {
    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.didFailToLoadAd = ^{
        // Expecting load failure due to no configuration response.
        // This doesn't matter since we are just verifying the URL that
        // is being sent to the Ad Server communicator.
        [expectation fulfill];
    };

    NSString * adUnitId = [NSString stringWithFormat:@"%@:%s", kTestAdUnitId, __FUNCTION__];

    MPMockAdServerCommunicator * mockAdServerCommunicator = nil;
    MPRewardedVideoAdManager * manager = [MPRewardedVideo makeAdManagerForAdUnitId:adUnitId];
    manager.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
        mockAdServerCommunicator = mock;
        mock;
    });
    [MPRewardedVideo setDelegate:delegateHandler forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withMediationSettings:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    [MPRewardedVideo removeDelegateForAdUnitId:adUnitId];

    XCTAssertNotNil(mockAdServerCommunicator);
    XCTAssertNotNil(mockAdServerCommunicator.lastUrlLoaded);

    MPURL * url = [mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);

    NSNumber * sc = [url numberForPOSTDataKey:kScaleFactorKey];
    NSNumber * cw = [url numberForPOSTDataKey:kCreativeSafeWidthKey];
    NSNumber * ch = [url numberForPOSTDataKey:kCreativeSafeHeightKey];
    CGRect frame = MPApplicationFrame(YES);
    XCTAssert(cw.floatValue == frame.size.width * sc.floatValue);
    XCTAssert(ch.floatValue == frame.size.height * sc.floatValue);
}

@end
