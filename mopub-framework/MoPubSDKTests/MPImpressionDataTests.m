//
//  MPImpressionDataTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPImpressionData.h"
#import "MPAdServerKeys.h"

@interface MPImpressionDataTests : XCTestCase

@property (nonatomic, strong) NSMutableDictionary * testImpressionData;

@end

@implementation MPImpressionDataTests

- (void)setUp {
    [super setUp];

    self.testImpressionData = [@{
                                 kImpressionDataImpressionIDKey : @"abcd-abcd-abcd-abcd",
                                 kImpressionDataPublisherRevenueKey : @(0.0000015),
                                 kImpressionDataAdUnitIDKey : @"FAKE_AD_UNIT",
                                 kImpressionDataAdUnitNameKey : @"Test Fullscreen (fake name)",
                                 kImpressionDataAdUnitFormatKey : @"320x50",
                                 kImpressionDataCurrencyKey : @"USD",
                                 kImpressionDataAdGroupIDKey : @"Test Ad Group ID",
                                 kImpressionDataAdGroupTypeKey : @"Test Ad Group Type",
                                 kImpressionDataAdGroupNameKey : @"Test Ad Group Name",
                                 kImpressionDataAdGroupPriorityKey : @(6),
                                 kImpressionDataCountryKey : @"US",
                                 kImpressionDataPrecisionKey : @"estimated",
                                 kImpressionDataNetworkNameKey : @"Facebook",
                                 kImpressionDataNetworkPlacementIDKey : @"Network Placement ID",
                                 } mutableCopy];
}

- (void)testBasicValuesPipedThrough {
    MPImpressionData * impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];

    // Numbers
    XCTAssert([impData.publisherRevenue isEqualToNumber:self.testImpressionData[kImpressionDataPublisherRevenueKey]]);
    XCTAssert([impData.adGroupPriority isEqualToNumber:self.testImpressionData[kImpressionDataAdGroupPriorityKey]]);

    // Strings
    XCTAssert([impData.impressionID isEqualToString:self.testImpressionData[kImpressionDataImpressionIDKey]]);
    XCTAssert([impData.adUnitID isEqualToString:self.testImpressionData[kImpressionDataAdUnitIDKey]]);
    XCTAssert([impData.adUnitName isEqualToString:self.testImpressionData[kImpressionDataAdUnitNameKey]]);
    XCTAssert([impData.adUnitFormat isEqualToString:self.testImpressionData[kImpressionDataAdUnitFormatKey]]);
    XCTAssert([impData.currency isEqualToString:self.testImpressionData[kImpressionDataCurrencyKey]]);
    XCTAssert([impData.adGroupID isEqualToString:self.testImpressionData[kImpressionDataAdGroupIDKey]]);
    XCTAssert([impData.adGroupName isEqualToString:self.testImpressionData[kImpressionDataAdGroupNameKey]]);
    XCTAssert([impData.country isEqualToString:self.testImpressionData[kImpressionDataCountryKey]]);
    XCTAssert([impData.networkName isEqualToString:self.testImpressionData[kImpressionDataNetworkNameKey]]);
    XCTAssert([impData.networkPlacementID isEqualToString:self.testImpressionData[kImpressionDataNetworkPlacementIDKey]]);
}

- (void)testBasicValuesPipedThroughWithNilValues {
    self.testImpressionData[kImpressionDataNetworkNameKey] = nil;
    self.testImpressionData[kImpressionDataNetworkPlacementIDKey] = nil;
    self.testImpressionData[kImpressionDataCountryKey] = nil;

    MPImpressionData * impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];

    // Numbers
    XCTAssert([impData.publisherRevenue isEqualToNumber:self.testImpressionData[kImpressionDataPublisherRevenueKey]]);
    XCTAssert([impData.adGroupPriority isEqualToNumber:self.testImpressionData[kImpressionDataAdGroupPriorityKey]]);

    // Strings
    XCTAssert([impData.impressionID isEqualToString:self.testImpressionData[kImpressionDataImpressionIDKey]]);
    XCTAssert([impData.adUnitID isEqualToString:self.testImpressionData[kImpressionDataAdUnitIDKey]]);
    XCTAssert([impData.adUnitName isEqualToString:self.testImpressionData[kImpressionDataAdUnitNameKey]]);
    XCTAssert([impData.adUnitFormat isEqualToString:self.testImpressionData[kImpressionDataAdUnitFormatKey]]);
    XCTAssert([impData.currency isEqualToString:self.testImpressionData[kImpressionDataCurrencyKey]]);
    XCTAssert([impData.adGroupID isEqualToString:self.testImpressionData[kImpressionDataAdGroupIDKey]]);
    XCTAssert([impData.adGroupName isEqualToString:self.testImpressionData[kImpressionDataAdGroupNameKey]]);
    XCTAssertNil(impData.country);
    XCTAssertNil(impData.networkName);
    XCTAssertNil(impData.networkPlacementID);
}

- (void)testPrecisionEnum {
    self.testImpressionData[kImpressionDataPrecisionKey] = nil;
    MPImpressionData * impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];
    XCTAssert(impData.precision == MPImpressionDataPrecisionUnknown);

    self.testImpressionData[kImpressionDataPrecisionKey] = @"estimated";
    impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];
    XCTAssert(impData.precision == MPImpressionDataPrecisionEstimated);

    self.testImpressionData[kImpressionDataPrecisionKey] = @"publisher_defined";
    impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];
    XCTAssert(impData.precision == MPImpressionDataPrecisionPublisherDefined);

    self.testImpressionData[kImpressionDataPrecisionKey] = @"exact";
    impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];
    XCTAssert(impData.precision == MPImpressionDataPrecisionExact);

    self.testImpressionData[kImpressionDataPrecisionKey] = @"corrupt value";
    impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];
    XCTAssert(impData.precision == MPImpressionDataPrecisionUnknown);
}

- (void)testJsonRepresentationWithNetworks {
    MPImpressionData * impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];

    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:impData.jsonRepresentation
                                                              options:0
                                                                error:nil];
    XCTAssert([self.testImpressionData isEqualToDictionary:jsonDict]);
}

- (void)testJsonRepresentationWithoutNetworks {
    self.testImpressionData[kImpressionDataNetworkNameKey] = nil;
    self.testImpressionData[kImpressionDataNetworkPlacementIDKey] = nil;
    MPImpressionData * impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];

    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:impData.jsonRepresentation
                                                              options:0
                                                                error:nil];
    XCTAssert([self.testImpressionData isEqualToDictionary:jsonDict]);
    XCTAssertNil(self.testImpressionData[kImpressionDataNetworkNameKey]);
    XCTAssertNil(self.testImpressionData[kImpressionDataNetworkPlacementIDKey]);
}

- (void)testJsonRepresentationWithExtraKeys {
    NSString * testKey = @"test key";
    NSString * testValue = @"test value";
    self.testImpressionData[testKey] = testValue;
    MPImpressionData * impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];

    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:impData.jsonRepresentation
                                                              options:0
                                                                error:nil];
    XCTAssert([self.testImpressionData isEqualToDictionary:jsonDict]);
    XCTAssert([testValue isEqualToString:jsonDict[testKey]]);
}

- (void)testNullPublisherRevenueValue {
    self.testImpressionData[kImpressionDataPublisherRevenueKey] = [NSNull null];

    MPImpressionData * impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];

    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:impData.jsonRepresentation
                                                              options:0
                                                                error:nil];

    XCTAssertNil(impData.publisherRevenue);
    XCTAssert([jsonDict[kImpressionDataPublisherRevenueKey] isKindOfClass:[NSNull class]]);
}

- (void)testNullPrecisionValue {
    self.testImpressionData[kImpressionDataPrecisionKey] = [NSNull null];

    MPImpressionData * impData = [[MPImpressionData alloc] initWithDictionary:self.testImpressionData];

    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:impData.jsonRepresentation
                                                              options:0
                                                                error:nil];

    XCTAssert(impData.precision == MPImpressionDataPrecisionUnknown);
    XCTAssert([jsonDict[kImpressionDataPrecisionKey] isKindOfClass:[NSNull class]]);
}

@end
