//
//  MOPUBNativeVideoAdAdapterTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MOPUBNativeVideoAdAdapter+Testing.h"
#import "MPAdConfigurationFactory.h"
#import "MPAdImpressionTimer+Testing.h"
#import "MPGlobal.h"
#import "MPNativeAdConstants.h"
#import "MOPUBNativeVideoAdConfigValues.h"
#import "MPMockAdDestinationDisplayAgent.h"

@interface MOPUBNativeVideoAdAdapterTests : XCTestCase

@end

@implementation MOPUBNativeVideoAdAdapterTests

#pragma mark - Privacy Icon Overrides

- (void)testPrivacyIconNoOverrideSuccess {
    NSMutableDictionary * properties = [MPAdConfigurationFactory defaultNativeProperties];
    properties[kAdPrivacyIconImageUrlKey] = nil;

    MOPUBNativeVideoAdAdapter * adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:properties];

    // Verify that the default icon path to resource is used.
    XCTAssert([[adapter.properties objectForKey:kAdPrivacyIconImageUrlKey] isEqualToString:MPResourcePathForResource(kPrivacyIconImageName)]);
    XCTAssertNotNil([adapter.properties objectForKey:kAdPrivacyIconUIImageKey]);
}

- (void)testPrivacyIconOverrideSuccess {
    NSMutableDictionary * properties = [MPAdConfigurationFactory defaultNativeProperties];
    properties[kAdPrivacyIconImageUrlKey] = @"http://www.mopub.com/unittest.jpg";

    MOPUBNativeVideoAdAdapter * adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:properties];

    // Verify that the override URL has not been overwritten by the default icon
    // path to resource.
    XCTAssert([[adapter.properties objectForKey:kAdPrivacyIconImageUrlKey] isEqualToString:@"http://www.mopub.com/unittest.jpg"]);
    XCTAssertNil([adapter.properties objectForKey:kAdPrivacyIconUIImageKey]);
}

- (void)testPrivacyClickthroughNoOverrideSuccess {
    NSMutableDictionary * properties = [MPAdConfigurationFactory defaultNativeProperties];
    properties[kAdPrivacyIconClickUrlKey] = nil;

    MOPUBNativeVideoAdAdapter * adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:properties];
    MPMockAdDestinationDisplayAgent * displayAgent = [MPMockAdDestinationDisplayAgent new];
    adapter.destinationDisplayAgent = displayAgent;

    [adapter displayContentForDAAIconTap];
    XCTAssert([displayAgent.lastDisplayDestinationUrl.absoluteString isEqualToString:kPrivacyIconTapDestinationURL]);
}

- (void)testPrivacyClickthroughOverrideSuccess {
    NSMutableDictionary * properties = [MPAdConfigurationFactory defaultNativeProperties];
    properties[kAdPrivacyIconClickUrlKey] = @"http://www.mopub.com/unittest/success";

    MOPUBNativeVideoAdAdapter * adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:properties];
    MPMockAdDestinationDisplayAgent * displayAgent = [MPMockAdDestinationDisplayAgent new];
    adapter.destinationDisplayAgent = displayAgent;

    [adapter displayContentForDAAIconTap];
    XCTAssert([displayAgent.lastDisplayDestinationUrl.absoluteString isEqualToString:@"http://www.mopub.com/unittest/success"]);
}

#pragma mark - Testing impression tracking header rules

- (void)testValidPixelsAndTime {
    MOPUBNativeVideoAdConfigValues *config = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50
                                                                                            pauseVisiblePercent:50
                                                                                     impressionMinVisiblePixels:1
                                                                                    impressionMinVisiblePercent:-1
                                                                                    impressionMinVisibleSeconds:30
                                                                                               maxBufferingTime:10
                                                                                                       trackers:nil];
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      kAdIconImageKey: @"",
                                                                                      kAdMainImageKey: @"",
                                                                                      kAdTextKey: @"",
                                                                                      kAdTitleKey: @"",
                                                                                      kAdCTATextKey: @"",
                                                                                      kVASTVideoKey: @"",
                                                                                      kImpressionTrackerURLsKey: @[@"https://google.com"],
                                                                                      kClickTrackerURLKey: @[@"https://google.com"],
                                                                                      kNativeAdConfigKey: config,
                                                                                      }];
    MOPUBNativeVideoAdAdapter *adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:properties];
    [adapter willAttachToView:[[UIView alloc] init]];

    XCTAssertEqual(config.impressionMinVisiblePixels, adapter.impressionTimer.pixelsRequiredForViewVisibility);
    XCTAssertNotEqual(config.impressionMinVisiblePercent * 0.01f, adapter.impressionTimer.percentageRequiredForViewVisibility);
    XCTAssertEqual(config.impressionMinVisibleSeconds, adapter.impressionTimer.requiredSecondsForImpression);
}

- (void)testValidPixelsTakesPriorityOverPercentWithValidTime {
    MOPUBNativeVideoAdConfigValues *config = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50
                                                                                            pauseVisiblePercent:50
                                                                                     impressionMinVisiblePixels:1
                                                                                    impressionMinVisiblePercent:50
                                                                                    impressionMinVisibleSeconds:30
                                                                                               maxBufferingTime:10
                                                                                                       trackers:nil];
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      kAdIconImageKey: @"",
                                                                                      kAdMainImageKey: @"",
                                                                                      kAdTextKey: @"",
                                                                                      kAdTitleKey: @"",
                                                                                      kAdCTATextKey: @"",
                                                                                      kVASTVideoKey: @"",
                                                                                      kImpressionTrackerURLsKey: @[@"https://google.com"],
                                                                                      kClickTrackerURLKey: @[@"https://google.com"],
                                                                                      kNativeAdConfigKey: config,
                                                                                      }];
    MOPUBNativeVideoAdAdapter *adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:properties];
    [adapter willAttachToView:[[UIView alloc] init]];

    XCTAssertEqual(config.impressionMinVisiblePixels, adapter.impressionTimer.pixelsRequiredForViewVisibility);
    XCTAssertNotEqual(config.impressionMinVisiblePercent * 0.01f, adapter.impressionTimer.percentageRequiredForViewVisibility);
    XCTAssertEqual(config.impressionMinVisibleSeconds, adapter.impressionTimer.requiredSecondsForImpression);
}

- (void)testValidPercentAndTime {
    MOPUBNativeVideoAdConfigValues *config = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50
                                                                                            pauseVisiblePercent:50
                                                                                     impressionMinVisiblePixels:-1
                                                                                    impressionMinVisiblePercent:50
                                                                                    impressionMinVisibleSeconds:30
                                                                                               maxBufferingTime:10
                                                                                                       trackers:nil];
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      kAdIconImageKey: @"",
                                                                                      kAdMainImageKey: @"",
                                                                                      kAdTextKey: @"",
                                                                                      kAdTitleKey: @"",
                                                                                      kAdCTATextKey: @"",
                                                                                      kVASTVideoKey: @"",
                                                                                      kImpressionTrackerURLsKey: @[@"https://google.com"],
                                                                                      kClickTrackerURLKey: @[@"https://google.com"],
                                                                                      kNativeAdConfigKey: config,
                                                                                      }];
    MOPUBNativeVideoAdAdapter *adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:properties];
    [adapter willAttachToView:[[UIView alloc] init]];

    XCTAssertNotEqual(config.impressionMinVisiblePixels, adapter.impressionTimer.pixelsRequiredForViewVisibility);
    XCTAssertEqual(config.impressionMinVisiblePercent * 0.01f, adapter.impressionTimer.percentageRequiredForViewVisibility);
    XCTAssertEqual(config.impressionMinVisibleSeconds, adapter.impressionTimer.requiredSecondsForImpression);
}

@end
