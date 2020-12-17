//
//  MPMoPubConfigurationTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPMoPubConfiguration.h"

static NSString * const kAdUnitId = @"FAKE_ID";

@interface MPMoPubConfigurationTests : XCTestCase

@end

@implementation MPMoPubConfigurationTests

#pragma mark - Network Configurations

- (void)testSetNetworkConfigurationSuccess {
    NSDictionary<NSString *, NSString *> * params = @{ @"key": @"test" };
    NSString * const adapterName = @"MPMockAdColonyAdapterConfiguration";

    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:kAdUnitId];
    [config setNetworkConfiguration:params forMediationAdapter:adapterName];

    XCTAssertNotNil(config.mediatedNetworkConfigurations);
    XCTAssertNotNil(config.mediatedNetworkConfigurations[adapterName]);
    XCTAssert([config.mediatedNetworkConfigurations[adapterName][@"key"] isEqualToString:@"test"]);
}

- (void)testSetNetworkConfigurationFail {
    NSDictionary<NSString *, NSString *> * params = @{ @"key": @"test" };
    NSString * const adapterName = @"MPMockUnknownAdapterConfiguration";

    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:kAdUnitId];
    [config setNetworkConfiguration:params forMediationAdapter:adapterName];

    XCTAssertNil(config.mediatedNetworkConfigurations);
}

@end
