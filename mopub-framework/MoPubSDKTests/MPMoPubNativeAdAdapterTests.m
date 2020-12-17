//
//  MPMoPubNativeAdAdapterTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPMoPubNativeAdAdapter+Testing.h"
#import "MPAdConfigurationFactory.h"
#import "MPAdImpressionTimer+Testing.h"
#import "MPGlobal.h"
#import "MPMockAdDestinationDisplayAgent.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdConfigValues.h"

@interface MPMoPubNativeAdAdapterTests : XCTestCase

@end

@implementation MPMoPubNativeAdAdapterTests

#pragma mark - Privacy Icon Overrides

- (void)testPrivacyIconNoOverrideSuccess {
    NSMutableDictionary * properties = [MPAdConfigurationFactory defaultNativeProperties];
    properties[kAdPrivacyIconImageUrlKey] = nil;

    MPMoPubNativeAdAdapter * adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:properties];

    // Verify that the default icon path to resource is used.
    XCTAssert([[adapter.properties objectForKey:kAdPrivacyIconImageUrlKey] isEqualToString:MPResourcePathForResource(kPrivacyIconImageName)]);
    XCTAssertNotNil([adapter.properties objectForKey:kAdPrivacyIconUIImageKey]);
}

- (void)testPrivacyIconOverrideSuccess {
    NSMutableDictionary * properties = [MPAdConfigurationFactory defaultNativeProperties];
    properties[kAdPrivacyIconImageUrlKey] = @"http://www.mopub.com/unittest.jpg";

    MPMoPubNativeAdAdapter * adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:properties];

    // Verify that the override URL has not been overwritten by the default icon
    // path to resource.
    XCTAssert([[adapter.properties objectForKey:kAdPrivacyIconImageUrlKey] isEqualToString:@"http://www.mopub.com/unittest.jpg"]);
    XCTAssertNil([adapter.properties objectForKey:kAdPrivacyIconUIImageKey]);
}

- (void)testPrivacyClickthroughNoOverrideSuccess {
    NSMutableDictionary * properties = [MPAdConfigurationFactory defaultNativeProperties];
    properties[kAdPrivacyIconClickUrlKey] = nil;

    MPMoPubNativeAdAdapter * adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:properties];
    MPMockAdDestinationDisplayAgent * displayAgent = [MPMockAdDestinationDisplayAgent new];
    adapter.destinationDisplayAgent = displayAgent;

    [adapter displayContentForDAAIconTap];
    XCTAssert([displayAgent.lastDisplayDestinationUrl.absoluteString isEqualToString:kPrivacyIconTapDestinationURL]);
}

- (void)testPrivacyClickthroughOverrideSuccess {
    NSMutableDictionary * properties = [MPAdConfigurationFactory defaultNativeProperties];
    properties[kAdPrivacyIconClickUrlKey] = @"http://www.mopub.com/unittest/success";

    MPMoPubNativeAdAdapter * adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:properties];
    MPMockAdDestinationDisplayAgent * displayAgent = [MPMockAdDestinationDisplayAgent new];
    adapter.destinationDisplayAgent = displayAgent;

    [adapter displayContentForDAAIconTap];
    XCTAssert([displayAgent.lastDisplayDestinationUrl.absoluteString isEqualToString:@"http://www.mopub.com/unittest/success"]);
}

#pragma mark - Impression timer gets set correctly

- (void)testImpressionRulesTimerSetFromHeaderPropertiesPixels {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:30
                                                                                  impressionMinVisiblePercent:-1
                                                                                  impressionMinVisibleSeconds:5.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.pixelsRequiredForViewVisibility, configValues.impressionMinVisiblePixels);
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertFalse(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertTrue(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertTrue(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesPixelsTakePriorityOverPercentage {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:30
                                                                                  impressionMinVisiblePercent:30
                                                                                  impressionMinVisibleSeconds:5.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.pixelsRequiredForViewVisibility, configValues.impressionMinVisiblePixels);
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertNotEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, configValues.impressionMinVisiblePercent);
    XCTAssertTrue(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertTrue(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertTrue(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesTimerSetFromHeaderPropertiesPercentage {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0 // invalid pixels to fall through
                                                                                  impressionMinVisiblePercent:30
                                                                                  impressionMinVisibleSeconds:5.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    CGFloat percentage = (configValues.impressionMinVisiblePercent / 100.0);
    XCTAssertEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, percentage);
    XCTAssertTrue(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertTrue(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesDefaultsAreUsedWhenHeaderPropertiesAreInvalid {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                                                  impressionMinVisiblePercent:-1
                                                                                  impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertNotEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertNotEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, (configValues.impressionMinVisiblePercent / 100.0));
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 1.0);
    XCTAssertEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, 0.5);
    XCTAssertFalse(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesPropertiesDictionaryDoesNotContainConfigAfterInit {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                                                  impressionMinVisiblePercent:-1
                                                                                  impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];
    XCTAssertNil(adapter.properties[kNativeAdConfigKey]);
}

- (void)testImpressionRulesOnlyValidPixels {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:20
                                                                                  impressionMinVisiblePercent:-1
                                                                                  impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.pixelsRequiredForViewVisibility, configValues.impressionMinVisiblePixels);
    XCTAssertNotEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 1.0); // check for default
    XCTAssertFalse(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertTrue(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesOnlyValidPercentage {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                                                  impressionMinVisiblePercent:10
                                                                                  impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertNotEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    CGFloat percentage = (configValues.impressionMinVisiblePercent / 100.0);
    XCTAssertEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, percentage);
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 1.0);
    CGFloat expected = 0.1;
    XCTAssertEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, expected);
    XCTAssertTrue(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesOnlyValidTimeInterval {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                                                  impressionMinVisiblePercent:-1
                                                                                  impressionMinVisibleSeconds:30.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertNotEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, (configValues.impressionMinVisiblePercent / 100.0));
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 30.0);
    XCTAssertEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, 0.5);
    XCTAssertFalse(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertTrue(configValues.isImpressionMinVisibleSecondsValid);
}

@end
