//
//  MPAdConfigurationTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPAdConfigurationFactory.h"
#import "MPVASTTrackingEvent.h"
#import "MPRewardedVideoReward.h"
#import "MOPUBExperimentProvider.h"
#import "MPAdConfiguration+Testing.h"
#import "MPViewabilityTracker.h"
#import "MPAdServerKeys.h"

extern NSString * const kNativeImpressionVisibleMsMetadataKey;
extern NSString * const kNativeImpressionMinVisiblePercentMetadataKey;
extern NSString * const kNativeImpressionMinVisiblePixelsMetadataKey;

@interface MPAdConfigurationTests : XCTestCase

@end

@implementation MPAdConfigurationTests

- (void)setUp {
    [super setUp];
    [MPViewabilityTracker initialize];
}

#pragma mark - Rewarded Ads

- (void)testRewardedPlayableDurationParseStringInputSuccess {
    NSDictionary * headers = @{ kRewardedPlayableDurationMetadataKey: @"30" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.rewardedPlayableDuration, 30);
}

- (void)testRewardedPlayableDurationParseNumberInputSuccess {
    NSDictionary * headers = @{ kRewardedPlayableDurationMetadataKey: @(30) };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.rewardedPlayableDuration, 30);
}

- (void)testRewardedPlayableDurationParseNoHeader {
    NSDictionary * headers = @{ };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.rewardedPlayableDuration, -1);
}

- (void)testRewardedPlayableRewardOnClickParseSuccess {
    NSDictionary * headers = @{ kRewardedPlayableRewardOnClickMetadataKey: @"true" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.rewardedPlayableShouldRewardOnClick, true);
}

- (void)testRewardedPlayableRewardOnClickParseNoHeader {
    NSDictionary * headers = @{ };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.rewardedPlayableShouldRewardOnClick, false);
}

- (void)testRewardedSingleCurrencyParseSuccess {
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                               };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(config.selectedReward.amount.integerValue == 3);
}

- (void)testRewardedMultiCurrencyParseSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name@": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 3);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:@"Coins"]);
    XCTAssert(config.selectedReward.amount.integerValue == 8);
}

- (void)testRewardedMultiCurrencyParseFailure {
    // {
    //   "rewards": []
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:kMPRewardedVideoRewardCurrencyTypeUnspecified]);
    XCTAssert(config.selectedReward.amount.integerValue == kMPRewardedVideoRewardCurrencyAmountUnspecified);
}

- (void)testRewardedMultiCurrencyParseFailureMalconfiguredReward {
    // {
    //   "rewards": [ { "n": "Coins", "a": 8 } ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"n": @"Coins", @"a": @(8) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:kMPRewardedVideoRewardCurrencyTypeUnspecified]);
    XCTAssert(config.selectedReward.amount.integerValue == kMPRewardedVideoRewardCurrencyAmountUnspecified);
}

- (void)testRewardedMultiCurrencyParseFailoverToSingleCurrencySuccess {
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                kRewardedCurrenciesMetadataKey: @{ }
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(config.selectedReward.amount.integerValue == 3);
}

#pragma mark - Native Trackers

- (void)testNativeVideoTrackersNoHeader
{
    MPAdConfiguration *config = [MPAdConfigurationFactory defaultNativeAdConfiguration];
    XCTAssertNil(config.nativeVideoTrackers);
}

// @"{
//    "urls": ["http://mopub.com/%%VIDEO_EVENT%%/foo", "http://mopub.com/%%VIDEO_EVENT%%/bar"],
//    "events": ["start", "firstQuartile", "midpoint", "thirdQuartile", "complete"]
//   }"
- (void)testNaiveVideoTrackers {
    MPAdConfiguration *config = [MPAdConfigurationFactory defaultNativeVideoConfigurationWithVideoTrackers];
    XCTAssertNotNil(config.nativeVideoTrackers);
    XCTAssertEqual(config.nativeVideoTrackers.count, 5);
    XCTAssertEqual(((NSArray *)config.nativeVideoTrackers[MPVASTTrackingEventTypeStart]).count, 2);
    XCTAssertEqual(((NSArray *)config.nativeVideoTrackers[MPVASTTrackingEventTypeFirstQuartile]).count, 2);
    XCTAssertEqual(((NSArray *)config.nativeVideoTrackers[MPVASTTrackingEventTypeMidpoint]).count, 2);
    XCTAssertEqual(((NSArray *)config.nativeVideoTrackers[MPVASTTrackingEventTypeThirdQuartile]).count, 2);
    XCTAssertEqual(((NSArray *)config.nativeVideoTrackers[MPVASTTrackingEventTypeComplete]).count, 2);
}

#pragma mark - Clickthrough experiments test

- (void)testClickthroughExperimentDefault {
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil adType:MPAdTypeFullscreen];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeInApp);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeInApp);
}

- (void)testClickthroughExperimentInApp {
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"0"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeInApp);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeInApp);
}

- (void)testClickthroughExperimentNativeBrowser {
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"1"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeNativeSafari);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeNativeSafari);
}

- (void)testClickthroughExperimentSafariViewController {
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"2"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeSafariViewController);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeSafariViewController);
#pragma clang diagnostic pop
}

#pragma mark - Viewability

- (void)testDisableAllViewability {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // {
    //   "X-Disable-Viewability": 3
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"3" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config);

    // All viewability vendors should be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);
}

- (void)testDisableNoViewability {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // {
    //   "X-Disable-Viewability": 0
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"0" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config);

    // IAS should still be enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);
}

- (void)testEnableAlreadyDisabledViewability {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // {
    //   "X-Disable-Viewability": 3
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"3" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config);

    // All viewability vendors should be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);

    // Reset local variables for reuse.
    headers = nil;
    config = nil;

    // {
    //   "X-Disable-Viewability": 0
    // }
    headers = @{ kViewabilityDisableMetadataKey: @"0" };
    config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config);

    // All viewability vendors should still be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);
}

- (void)testInvalidViewabilityHeaderValue {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // {
    //   "X-Disable-Viewability": 3aaaa
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"aaaa" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config);

    // IAS should still be enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);
}

- (void)testEmptyViewabilityHeaderValue {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // {
    //   "X-Disable-Viewability": ""
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNotNil(config);

    // IAS should still be enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);
}

#pragma mark - Static Native Ads

- (void)testMinVisiblePixelsParseSuccess {
    NSDictionary *headers = @{ kNativeImpressionMinVisiblePixelsMetadataKey: @"50" };
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.nativeImpressionMinVisiblePixels, 50.0);
}

- (void)testMinVisiblePixelsParseNoHeader {
    NSDictionary *headers = @{};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.nativeImpressionMinVisiblePixels, -1.0);
}

- (void)testMinVisiblePercentParseSuccess {
    NSDictionary *headers = @{ kNativeImpressionMinVisiblePercentMetadataKey: @"50" };
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.nativeImpressionMinVisiblePercent, 50);
}

- (void)testMinVisiblePercentParseNoHeader {
    NSDictionary *headers = @{};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.nativeImpressionMinVisiblePercent, -1);
}

- (void)testMinVisibleTimeIntervalParseSuccess {
    NSDictionary *headers = @{ kNativeImpressionVisibleMsMetadataKey: @"1500" };
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.nativeImpressionMinVisibleTimeInterval, 1.5);
}

- (void)testMinVisibleTimeIntervalParseNoHeader {
    NSDictionary *headers = @{};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertEqual(config.nativeImpressionMinVisibleTimeInterval, -1);
}

#pragma mark - Banner Impression Headers

- (void)testVisibleImpressionHeader {
    NSDictionary * headers = @{ kBannerImpressionVisableMsMetadataKey: @"0", kBannerImpressionMinPixelMetadataKey:@"1"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];
    XCTAssertEqual(config.impressionMinVisiblePixels, 1);
    XCTAssertEqual(config.impressionMinVisibleTimeInSec, 0);
}

- (void)testVisibleImpressionEnabled {
    NSDictionary * headers = @{ kBannerImpressionVisableMsMetadataKey: @"0", kBannerImpressionMinPixelMetadataKey:@"1"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];
    XCTAssertTrue(config.visibleImpressionTrackingEnabled);
}

- (void)testVisibleImpressionEnabledNoHeader {
    NSDictionary * headers = @{};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];
    XCTAssertFalse(config.visibleImpressionTrackingEnabled);
}

- (void)testVisibleImpressionNotEnabled {
    NSDictionary * headers = @{kBannerImpressionVisableMsMetadataKey: @"0", kBannerImpressionMinPixelMetadataKey:@"0"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];
    XCTAssertFalse(config.visibleImpressionTrackingEnabled);
}

#pragma mark - Multiple Impression Tracking URLs

- (void)testMultipleImpressionTrackingURLs {
    NSDictionary * headers = @{ kImpressionTrackersMetadataKey: @[@"https://google.com", @"https://mopub.com", @"https://twitter.com"] };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssert(config.impressionTrackingURLs.count == 3);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://mopub.com"]]);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleImpressionTrackingURLIsFunctional {
    NSDictionary * headers = @{ kImpressionTrackerMetadataKey: @"https://twitter.com" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssert(config.impressionTrackingURLs.count == 1);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testMultipleImpressionTrackingURLsTakesPriorityOverSingleURL {
    NSDictionary * headers = @{
                               kImpressionTrackersMetadataKey: @[@"https://google.com", @"https://mopub.com"],
                               kImpressionTrackerMetadataKey: @"https://twitter.com"
                               };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssert(config.impressionTrackingURLs.count == 2);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://mopub.com"]]);
    XCTAssertFalse([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testLackOfImpressionTrackingURLResultsInNilArray {
    NSDictionary * headers = @{};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];

    XCTAssertNil(config.impressionTrackingURLs);
}

- (void)testMalformedURLsAreNotIncludedInAdConfiguration {
    NSDictionary * headers = @{
                               kImpressionTrackersMetadataKey: @[@"https://google.com", @"https://mopub.com", @"https://mopub.com/%%FAKEMACRO%%", @"absolutely not a URL"],
                               };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil adType:MPAdTypeFullscreen];
    XCTAssert(config.impressionTrackingURLs.count == 2);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://mopub.com"]]);
}

#pragma mark - Single vs Multiple URL Separator

- (void)testSingleValidURL {
    NSString * url = @"https://google.com";
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": url };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil adType:MPAdTypeFullscreen];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];

    XCTAssert(strings.count == 1);
    XCTAssert([strings.firstObject isEqualToString:url]);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:url]);
}

- (void)testMultipleValidURLs {
    NSArray * urlStrings = @[@"https://google.com", @"https://twitter.com"];
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": urlStrings };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil adType:MPAdTypeFullscreen];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];

    XCTAssert(strings.count == 2);
    XCTAssert([strings containsObject:urlStrings[0]]);
    XCTAssert([strings containsObject:urlStrings[1]]);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:urlStrings[0]]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:urlStrings[1]]]);
}

- (void)testMultipleInvalidItems {
    NSArray * urlStrings = @[@[], @{}, @[@"https://google.com"]];
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": urlStrings };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil adType:MPAdTypeFullscreen];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];
    XCTAssertNil(strings);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssertNil(urls);
}

- (void)testMultipleValidURLsWithMultipleInvalidItems {
    NSArray * urlStrings = @[@"https://google.com", @{@"test": @"test"}, @"https://twitter.com", @[@"test", @"test2"]];
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": urlStrings };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil adType:MPAdTypeFullscreen];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];

    XCTAssert(strings.count == 2);
    XCTAssert([strings containsObject:urlStrings[0]]);
    XCTAssert([strings containsObject:urlStrings[2]]);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:urlStrings[0]]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:urlStrings[2]]]);
}

- (void)testSingleInvalidItem {
    NSDictionary * urlStrings = @{};
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": urlStrings };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil adType:MPAdTypeFullscreen];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];
    XCTAssertNil(strings);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssertNil(urls);
}

- (void)testEmptyString {
    NSString * url = @"";
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": url };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil adType:MPAdTypeFullscreen];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];
    XCTAssertNil(strings);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssertNil(urls);
}

- (void)testInvalidUrlStringWontConvert {
    NSString * url = @"definitely not a url";
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": url };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssertNil(urls);
}

#pragma mark - After Load URLs

- (void)testSingleDefaultUrlBackwardsCompatibility {
    NSDictionary * metadata = @{ kAfterLoadUrlMetadataKey: @"https://google.com" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:@"https://google.com"]);
}

- (void)testNoDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadSuccessUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:@"https://google.com"]);
}

- (void)testNoDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadSuccessUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:@"https://twitter.com"]);
}

- (void)testNoDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadSuccessUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:@"https://twitter.com"]);
}

- (void)testNoDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadSuccessUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:@"https://twitter.com"]);
}

- (void)testSingleDefaultUrlAndSingleSuccessWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 1);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 1);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 1);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testSingleDefaultUrlAndSingleFailureWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 1);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testSingleDefaultUrlAndSingleFailureWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleFailureWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleFailureWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://testurl.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://testurl.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://testurl.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://testurl.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://testurl.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://testurl.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://testurl.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://testurl.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleFailureUrlsWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleFailureUrlsWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleFailureUrlsWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleFailureUrlsWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsAndMultipleFailureUrlsWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://fakeurl.com", @"https://fakeurl2.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://fakeurl.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://fakeurl2.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsAndMultipleFailureUrlsWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://fakeurl.com", @"https://fakeurl2.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl2.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsAndMultipleFailureUrlsWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://fakeurl.com", @"https://fakeurl2.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl2.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsAndMultipleFailureUrlsWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://fakeurl.com", @"https://fakeurl2.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl2.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

@end
