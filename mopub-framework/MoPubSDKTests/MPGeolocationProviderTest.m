//
//  MPGeolocationProviderTest.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPConsentManager+Testing.h"
#import "MoPub.h"

@interface MPGeolocationProviderTest : XCTestCase

@end

@implementation MPGeolocationProviderTest

- (void)setUp {
    [super setUp];
    [[MPConsentManager sharedManager] setUpConsentManagerForTesting];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLocationUpdatesEnabledNotGdprRegion {
    NSDictionary *response = @{
                              @"is_whitelisted": @"1",
                              @"is_gdpr_region": @"0",
                              @"call_again_after_secs": @"10",
                              @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                              @"current_privacy_policy_version": @"3.0.0",
                              @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                              @"current_vendor_list_version": @"4.0.0",
                              @"current_vendor_list_iab_format": @"yyyyy",
                              @"current_vendor_list_iab_hash": @"hash",
                              };
    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = [manager updateConsentStateWithParameters:response];
    XCTAssertTrue(success);

    [MoPub.sharedInstance setLocationUpdatesEnabled:YES];
    XCTAssertTrue(MoPub.sharedInstance.locationUpdatesEnabled);
}

- (void)testLocationUpdatesEnabledNotConsented {
    NSDictionary *response = @{
                               @"is_whitelisted": @"1",
                               @"is_gdpr_region": @"1",
                               @"call_again_after_secs": @"10",
                               @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                               @"current_privacy_policy_version": @"3.0.0",
                               @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                               @"current_vendor_list_version": @"4.0.0",
                               @"current_vendor_list_iab_format": @"yyyyy",
                               @"current_vendor_list_iab_hash": @"hash",
                               };
    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = [manager updateConsentStateWithParameters:response];
    XCTAssertTrue(success);

    [MoPub.sharedInstance setLocationUpdatesEnabled:YES];
    XCTAssertFalse(MoPub.sharedInstance.locationUpdatesEnabled);
}

@end
