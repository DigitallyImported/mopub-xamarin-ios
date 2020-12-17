//
//  MPConsentManagerTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdServerKeys.h"
#import "MPAdServerURLBuilder.h"
#import "MPConsentManager.h"
#import "MPConsentManager+Testing.h"
#import "MPConsentError.h"
#import "MPURL.h"

@interface MPConsentManagerTests : XCTestCase

@end

@implementation MPConsentManagerTests

- (void)setUp {
    [super setUp];

    [[MPConsentManager sharedManager] setUpConsentManagerForTesting];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Consent States

- (void)testSetConsentSuccess {
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = NO;

    // Consented
    success = [manager setCurrentStatus:MPConsentStatusConsented reason:@"Unit test: Consented" shouldBroadcast:YES];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);

    // Denied
    success = [manager setCurrentStatus:MPConsentStatusDenied reason:@"Unit test: Denied" shouldBroadcast:YES];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusDenied);

    // Unknown
    success = [manager setCurrentStatus:MPConsentStatusUnknown reason:@"Unit test: Unknown" shouldBroadcast:YES];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);

    // Do not track
    success = [manager setCurrentStatus:MPConsentStatusDoNotTrack reason:@"Unit test: Do not track" shouldBroadcast:YES];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusDoNotTrack);
}

- (void)testSetConsentFailure {
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = NO;

    // Consented
    success = [manager setCurrentStatus:MPConsentStatusConsented reason:@"Unit test" shouldBroadcast:YES];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);

    // Update with old time stamp
    success = [manager setCurrentStatus:MPConsentStatusConsented reason:@"Set again" shouldBroadcast:YES];
    XCTAssertFalse(success);
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.lastChangedReason isEqualToString:@"Unit test"]);
}

- (void)testUpdateConsentSuccess {
    NSDictionary * parameters = @{
      @"is_whitelisted": @"1",
      @"is_gdpr_region": @"1",
      @"call_again_after_secs": @"10",
      @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
      @"current_privacy_policy_version": @"3.0.0",
      @"current_vendor_list_link": @"http://www.mopub.com/vendors",
      @"current_vendor_list_version": @"4.0.0",
      @"current_vendor_list_iab_format": @"yyyyy",
      @"current_vendor_list_iab_hash": @"hash",
      @"extras": @"i'm extra!",
    };

    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = [manager updateConsentStateWithParameters:parameters];
    XCTAssertTrue(success);

    // Validate parsing
    XCTAssertTrue(manager.isWhitelisted);
    XCTAssertTrue(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.syncFrequency == 10);
    XCTAssert([manager.privacyPolicyUrl.absoluteString isEqualToString:@"http://www.mopub.com/privacy"]);
    XCTAssert([manager.privacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.vendorListUrl.absoluteString isEqualToString:@"http://www.mopub.com/vendors"]);
    XCTAssert([manager.vendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.iabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.iabVendorListHash isEqualToString:@"hash"]);
    XCTAssert([manager.extras isEqualToString:@"i'm extra!"]);
}

- (void)testUpdateConsentNotGDPRSuccess {
    NSDictionary * parameters = @{
                                  @"is_whitelisted": @"1",
                                  @"is_gdpr_region": @"0",
                                  @"call_again_after_secs": @"10",
                                  @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                                  @"current_privacy_policy_version": @"3.0.0",
                                  @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                                  @"current_vendor_list_version": @"4.0.0",
                                  @"current_vendor_list_iab_format": @"yyyyy",
                                  @"current_vendor_list_iab_hash": @"hash",
                                  @"extras": @"i'm extra!",
                                  };

    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    XCTAssertTrue(manager.isGDPRApplicable == MPBoolUnknown);
    BOOL success = [manager updateConsentStateWithParameters:parameters];
    XCTAssertTrue(success);

    // Validate parsing
    XCTAssertTrue(manager.isWhitelisted);
    XCTAssertTrue(manager.isGDPRApplicable == MPBoolNo);
    XCTAssert(manager.syncFrequency == 10);
    XCTAssert([manager.privacyPolicyUrl.absoluteString isEqualToString:@"http://www.mopub.com/privacy"]);
    XCTAssert([manager.privacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.vendorListUrl.absoluteString isEqualToString:@"http://www.mopub.com/vendors"]);
    XCTAssert([manager.vendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.iabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.iabVendorListHash isEqualToString:@"hash"]);
    XCTAssert([manager.extras isEqualToString:@"i'm extra!"]);
}

- (void)testUpdateConsentMacroReplacementSuccess {
    NSDictionary * parameters = @{
                                  @"is_whitelisted": @"1",
                                  @"is_gdpr_region": @"1",
                                  @"call_again_after_secs": @"10",
                                  @"current_privacy_policy_link": @"http://www.mopub.com/privacy?l=%%LANGUAGE%%",
                                  @"current_privacy_policy_version": @"3.0.0",
                                  @"current_vendor_list_link": @"http://www.mopub.com/vendors?l=%%LANGUAGE%%",
                                  @"current_vendor_list_version": @"4.0.0",
                                  @"current_vendor_list_iab_format": @"yyyyy",
                                  @"current_vendor_list_iab_hash": @"hash",
                                  };

    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = [manager updateConsentStateWithParameters:parameters];
    XCTAssertTrue(success);

    NSString * code = @"en";
    NSString * expectedPrivacyPolicyUrl = [NSString stringWithFormat:@"http://www.mopub.com/privacy?l=%@", code];
    NSString * expectedVendorListUrl = [NSString stringWithFormat:@"http://www.mopub.com/vendors?l=%@", code];

    // Validate parsing
    XCTAssertTrue(manager.isWhitelisted);
    XCTAssertTrue(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.syncFrequency == 10);
    XCTAssert([manager.privacyPolicyUrl.absoluteString isEqualToString:expectedPrivacyPolicyUrl]);
    XCTAssert([manager.privacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.vendorListUrl.absoluteString isEqualToString:expectedVendorListUrl]);
    XCTAssert([manager.vendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.iabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.iabVendorListHash isEqualToString:@"hash"]);
}

- (void)testUpdateConsentForceRevokeSuccess {
    NSDictionary * parameters = @{
                                  @"force_explicit_no": @"1",
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
    BOOL success = [manager updateConsentStateWithParameters:parameters];
    XCTAssertTrue(success);

    // Validate parsing
    XCTAssert(manager.currentStatus == MPConsentStatusDenied);
    XCTAssertTrue(manager.isWhitelisted);
    XCTAssertTrue(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.syncFrequency == 10);
    XCTAssert([manager.privacyPolicyUrl.absoluteString isEqualToString:@"http://www.mopub.com/privacy"]);
    XCTAssert([manager.privacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.vendorListUrl.absoluteString isEqualToString:@"http://www.mopub.com/vendors"]);
    XCTAssert([manager.vendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.iabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.iabVendorListHash isEqualToString:@"hash"]);
}

- (void)testUpdateConsentForceInvalidateConsentSuccess {
    NSDictionary * parameters = @{
                                  @"reacquire_consent": @"1",
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
    BOOL success = [manager updateConsentStateWithParameters:parameters];
    XCTAssertTrue(success);

    // Validate parsing
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);
    XCTAssertTrue(manager.isWhitelisted);
    XCTAssertTrue(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.syncFrequency == 10);
    XCTAssert([manager.privacyPolicyUrl.absoluteString isEqualToString:@"http://www.mopub.com/privacy"]);
    XCTAssert([manager.privacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.vendorListUrl.absoluteString isEqualToString:@"http://www.mopub.com/vendors"]);
    XCTAssert([manager.vendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.iabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.iabVendorListHash isEqualToString:@"hash"]);
}

- (void)testUpdateConsentNewPrivacyPolicyVersion {
    NSDictionary * before = @{
                              @"is_whitelisted": @"1",
                              @"is_gdpr_region": @"1",
                              @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                              @"current_privacy_policy_version": @"3.0.0",
                              @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                              @"current_vendor_list_version": @"4.0.0",
                              @"current_vendor_list_iab_format": @"yyyyy",
                              @"current_vendor_list_iab_hash": @"hash",
                              };

    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);

    // Grant consent
    [manager grantConsent];

    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);

    // Server now updates privacy policy version
    NSDictionary * after = @{
                             @"is_whitelisted": @"1",
                             @"is_gdpr_region": @"1",
                             @"current_privacy_policy_link": @"http://www.mopub.com/privacy/new",
                             @"current_privacy_policy_version": @"3.1.0",
                             @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                             @"current_vendor_list_version": @"4.0.0",
                             @"current_vendor_list_iab_format": @"yyyyy",
                             @"current_vendor_list_iab_hash": @"hash",
                             };
    success = [manager updateConsentStateWithParameters:after];
    XCTAssertTrue(success);

    // Validate transition
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.privacyPolicyUrl.absoluteString isEqualToString:@"http://www.mopub.com/privacy/new"]);
    XCTAssert([manager.privacyPolicyVersion isEqualToString:@"3.1.0"]);
    XCTAssert([manager.vendorListUrl.absoluteString isEqualToString:@"http://www.mopub.com/vendors"]);
    XCTAssert([manager.vendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.iabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.iabVendorListHash isEqualToString:@"hash"]);
}

- (void)testUpdateConsentNewVendorVersion {
    NSDictionary * before = @{
                              @"is_whitelisted": @"1",
                              @"is_gdpr_region": @"1",
                              @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                              @"current_privacy_policy_version": @"3.0.0",
                              @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                              @"current_vendor_list_version": @"4.0.0",
                              @"current_vendor_list_iab_format": @"yyyyy",
                              @"current_vendor_list_iab_hash": @"hash",
                              };

    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);

    // Grant consent
    [manager grantConsent];

    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);

    // Server now updates privacy policy version
    NSDictionary * after = @{
                             @"is_whitelisted": @"1",
                             @"is_gdpr_region": @"1",
                             @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                             @"current_privacy_policy_version": @"3.0.0",
                             @"current_vendor_list_link": @"http://www.mopub.com/vendors/new",
                             @"current_vendor_list_version": @"4.1.0",
                             @"current_vendor_list_iab_format": @"yyyyy",
                             @"current_vendor_list_iab_hash": @"hash",
                             };
    success = [manager updateConsentStateWithParameters:after];
    XCTAssertTrue(success);

    // Validate transition
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.privacyPolicyUrl.absoluteString isEqualToString:@"http://www.mopub.com/privacy"]);
    XCTAssert([manager.privacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.vendorListUrl.absoluteString isEqualToString:@"http://www.mopub.com/vendors/new"]);
    XCTAssert([manager.vendorListVersion isEqualToString:@"4.1.0"]);
    XCTAssert([manager.iabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.iabVendorListHash isEqualToString:@"hash"]);
}

- (void)testUpdateConsentNewIabVendorList {
    NSDictionary * before = @{
                              @"is_whitelisted": @"1",
                              @"is_gdpr_region": @"1",
                              @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                              @"current_privacy_policy_version": @"3.0.0",
                              @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                              @"current_vendor_list_version": @"4.0.0",
                              @"current_vendor_list_iab_format": @"yyyyy",
                              @"current_vendor_list_iab_hash": @"hash",
                              };

    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);

    // Grant consent
    [manager grantConsent];

    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);

    // Server now updates privacy policy version
    NSDictionary * after = @{
                             @"is_whitelisted": @"1",
                             @"is_gdpr_region": @"1",
                             @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                             @"current_privacy_policy_version": @"3.0.0",
                             @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                             @"current_vendor_list_version": @"4.0.0",
                             @"current_vendor_list_iab_format": @"zzzzzz",
                             @"current_vendor_list_iab_hash": @"hash_new",
                             };
    success = [manager updateConsentStateWithParameters:after];
    XCTAssertTrue(success);

    // Validate transition
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"zzzzzz"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.privacyPolicyUrl.absoluteString isEqualToString:@"http://www.mopub.com/privacy"]);
    XCTAssert([manager.privacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.vendorListUrl.absoluteString isEqualToString:@"http://www.mopub.com/vendors"]);
    XCTAssert([manager.vendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.iabVendorList isEqualToString:@"zzzzzz"]);
    XCTAssert([manager.iabVendorListHash isEqualToString:@"hash_new"]);
}

- (void)testUpdateConsentFailure {
    NSDictionary * parameters = @{
                                  @"reacquire_consent": @"1",
                                  @"is_whitelisted": @"1",
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
    BOOL success = [manager updateConsentStateWithParameters:parameters];
    XCTAssertFalse(success);
}

- (void)testTransitionFromPotentialWhitelistToConsented {
    NSDictionary * before = @{
                              @"is_whitelisted": @"0",
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);

    // Set to potential whitelist
    success = [manager setCurrentStatus:MPConsentStatusPotentialWhitelist reason:@"unit test" shouldBroadcast:YES];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusPotentialWhitelist);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);

    // Server now says publisher is whitelisted
    NSDictionary * after = @{
                              @"is_whitelisted": @"1",
                              @"is_gdpr_region": @"1",
                              @"call_again_after_secs": @"10",
                              @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                              @"current_privacy_policy_version": @"3.1.0",
                              @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                              @"current_vendor_list_version": @"4.1.0",
                              @"current_vendor_list_iab_format": @"zzzzz",
                              @"current_vendor_list_iab_hash": @"hash",
                              };
    success = [manager updateConsentStateWithParameters:after];
    XCTAssertTrue(success);

    // Validate transition
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssertTrue(manager.isWhitelisted);
    XCTAssertTrue(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.syncFrequency == 10);
    XCTAssert([manager.privacyPolicyUrl.absoluteString isEqualToString:@"http://www.mopub.com/privacy"]);
    XCTAssert([manager.privacyPolicyVersion isEqualToString:@"3.1.0"]);
    XCTAssert([manager.vendorListUrl.absoluteString isEqualToString:@"http://www.mopub.com/vendors"]);
    XCTAssert([manager.vendorListVersion isEqualToString:@"4.1.0"]);
    XCTAssert([manager.iabVendorList isEqualToString:@"zzzzz"]);
    XCTAssert([manager.iabVendorListHash isEqualToString:@"hash"]);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);
}

- (void)testTransitionFromUnknownToConsented {
    NSDictionary * before = @{
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);

    // Grant consent
    [manager grantConsent];

    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);
}

- (void)testTransitionToDenied {
    NSDictionary * before = @{
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);

    // Set consent to allowed.
    [manager grantConsent];

    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);

    // Deny consent
    [manager revokeConsent];

    XCTAssert(manager.currentStatus == MPConsentStatusDenied);
    XCTAssertNil(manager.consentedIabVendorList);
    XCTAssertNil(manager.consentedPrivacyPolicyVersion);
    XCTAssertNil(manager.consentedVendorListVersion);
}

- (void)testTransitionToDoNotTrack {
    NSDictionary * before = @{
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);

    // Set consent to allowed.
    [manager grantConsent];

    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);

    // Do not track
    [manager setCurrentStatus:MPConsentStatusDoNotTrack reason:@"stop tracking unit test" shouldBroadcast:YES];

    XCTAssert(manager.currentStatus == MPConsentStatusDoNotTrack);
    XCTAssertNil(manager.consentedIabVendorList);
    XCTAssertNil(manager.consentedPrivacyPolicyVersion);
    XCTAssertNil(manager.consentedVendorListVersion);
    XCTAssertFalse(manager.canCollectPersonalInfo);
}

- (void)testTransitionToDoNotTrackBackToUnknown {
    NSDictionary * before = @{
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);

    // Set consent to allowed.
    [manager grantConsent];

    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);

    // Do not track
    [manager setCurrentStatus:MPConsentStatusDoNotTrack reason:@"stop tracking unit test" shouldBroadcast:YES];

    XCTAssert(manager.currentStatus == MPConsentStatusDoNotTrack);
    XCTAssertNil(manager.consentedIabVendorList);
    XCTAssertNil(manager.consentedPrivacyPolicyVersion);
    XCTAssertNil(manager.consentedVendorListVersion);
    XCTAssertFalse(manager.canCollectPersonalInfo);

    // Transition to allow tracking
    [manager checkForDoNotTrackAndTransition];
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);
}

- (void)testTransitionToDoNotTrackBackToDenied {
    NSDictionary * before = @{
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);

    // Set consent to deny.
    [manager revokeConsent];

    XCTAssert(manager.currentStatus == MPConsentStatusDenied);
    XCTAssertNil(manager.consentedIabVendorList);
    XCTAssertNil(manager.consentedPrivacyPolicyVersion);
    XCTAssertNil(manager.consentedVendorListVersion);

    // Do not track
    [manager setCurrentStatus:MPConsentStatusDoNotTrack reason:@"stop tracking unit test" shouldBroadcast:YES];

    XCTAssert(manager.currentStatus == MPConsentStatusDoNotTrack);
    XCTAssertNil(manager.consentedIabVendorList);
    XCTAssertNil(manager.consentedPrivacyPolicyVersion);
    XCTAssertNil(manager.consentedVendorListVersion);
    XCTAssertFalse(manager.canCollectPersonalInfo);

    // Transition to allow tracking
    [manager checkForDoNotTrackAndTransition];
    XCTAssert(manager.currentStatus == MPConsentStatusDenied);
}

- (void)testReacquireConsent {
    NSDictionary * parameters = @{
                                  @"is_whitelisted": @"1",
                                  @"is_gdpr_region": @"1",
                                  @"reacquire_consent": @"1",
                                  @"call_again_after_secs": @"10",
                                  @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                                  @"current_privacy_policy_version": @"3.0.0",
                                  @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                                  @"current_vendor_list_version": @"4.0.0",
                                  @"current_vendor_list_iab_format": @"yyyyy",
                                  @"current_vendor_list_iab_hash": @"hash",
                                  @"extras": @"i'm extra!",
                                  };

    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = [manager updateConsentStateWithParameters:parameters];
    XCTAssertTrue(success);

    // Validate parsing
    XCTAssertTrue(manager.isConsentNeeded);
}

- (void)testTransitionToReacquireConsentYes {
    NSDictionary * before = @{
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);

    // Grant consent
    [manager grantConsent];
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssertFalse(manager.isConsentNeeded);

    // Server now says to reacquire consent, but no state change
    NSDictionary * after = @{
                             @"is_whitelisted": @"1",
                             @"is_gdpr_region": @"1",
                             @"reacquire_consent": @"1",
                             @"call_again_after_secs": @"10",
                             @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                             @"current_privacy_policy_version": @"3.0.0",
                             @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                             @"current_vendor_list_version": @"4.0.0",
                             @"current_vendor_list_iab_format": @"yyyyy",
                             @"current_vendor_list_iab_hash": @"hash",
                             };
    success = [manager updateConsentStateWithParameters:after];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssertTrue(manager.isConsentNeeded);

    // Grant consent again
    [manager grantConsent];
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssertFalse(manager.isConsentNeeded);
}

- (void)testTransitionToReacquireConsentNo {
    NSDictionary * before = @{
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);

    // Grant consent
    [manager grantConsent];
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssertFalse(manager.isConsentNeeded);

    // Server now says to reacquire consent, but no state change
    NSDictionary * after = @{
                             @"is_whitelisted": @"1",
                             @"is_gdpr_region": @"1",
                             @"reacquire_consent": @"1",
                             @"call_again_after_secs": @"10",
                             @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                             @"current_privacy_policy_version": @"3.0.0",
                             @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                             @"current_vendor_list_version": @"4.0.0",
                             @"current_vendor_list_iab_format": @"yyyyy",
                             @"current_vendor_list_iab_hash": @"hash",
                             };
    success = [manager updateConsentStateWithParameters:after];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssertTrue(manager.isConsentNeeded);

    // Deny consent
    [manager revokeConsent];
    XCTAssert(manager.currentStatus == MPConsentStatusDenied);
    XCTAssertFalse(manager.isConsentNeeded);
}

#pragma mark - forceIsGDPRApplicable property

- (void)testSetForceIsGDPRApplicableToYesFromUnknownMakesGDPRApplicable {
    MPConsentManager * manager = MPConsentManager.sharedManager;

    // Set before state
    [manager setIsGDPRApplicable:MPBoolUnknown];

    // Set forceIsGDPRApplicable
    manager.forceIsGDPRApplicable = YES;

    // Check after state
    XCTAssert(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.rawIsGDPRApplicable == MPBoolUnknown);
    XCTAssertTrue(manager.forceIsGDPRApplicable);
}

- (void)testSetForceIsGDPRApplicableToYesFromNoMakesGDPRApplicable {
    MPConsentManager * manager = MPConsentManager.sharedManager;

    // Set before state
    [manager setIsGDPRApplicable:MPBoolNo];

    // Set forceIsGDPRApplicable
    manager.forceIsGDPRApplicable = YES;

    // Check after state
    XCTAssert(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.rawIsGDPRApplicable == MPBoolNo);
    XCTAssertTrue(manager.forceIsGDPRApplicable);
}

- (void)testGDPRIsStillApplicableEvenIfForceIsGDPRApplicableIsFalse {
    MPConsentManager * manager = MPConsentManager.sharedManager;

    // Set before state
    [manager setIsGDPRApplicable:MPBoolYes];

    // Set forceIsGDPRApplicable
    manager.forceIsGDPRApplicable = NO;

    // Check after state
    XCTAssert(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.rawIsGDPRApplicable == MPBoolYes);
    XCTAssertFalse(manager.forceIsGDPRApplicable);
}

- (void)testGDPRIsNotApplicableWithoutForcingOrSetting {
    MPConsentManager * manager = MPConsentManager.sharedManager;

    // Set before state
    [manager setIsGDPRApplicable:MPBoolNo];

    // Set forceIsGDPRApplicable
    manager.forceIsGDPRApplicable = NO;

    // Check after state
    XCTAssert(manager.isGDPRApplicable == MPBoolNo);
    XCTAssert(manager.rawIsGDPRApplicable == MPBoolNo);
    XCTAssertFalse(manager.forceIsGDPRApplicable);
}

- (void)testGDPRApplicabilityDoesNotChangeAfterSettingForceIsGDPRApplicableToFalse {
    MPConsentManager * manager = MPConsentManager.sharedManager;

    // Set before state
    [manager setIsGDPRApplicable:MPBoolNo];

    // Set forceIsGDPRApplicable to YES
    manager.forceIsGDPRApplicable = YES;

    // Check after enabling forceIsGDPRApplicable
    XCTAssert(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.rawIsGDPRApplicable == MPBoolNo);
    XCTAssertTrue(manager.forceIsGDPRApplicable);

    // Set forceIsGDPRApplicable to NO
    manager.forceIsGDPRApplicable = NO;

    // Check after disabling forceIsGDPRApplicable
    XCTAssert(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.rawIsGDPRApplicable == MPBoolNo);
    XCTAssertTrue(manager.forceIsGDPRApplicable);
}

#pragma mark - forceStatus method

- (void)testForceStatusForceExplicitNo {
    NSDictionary * before = @{
                              @"is_whitelisted": @"0",
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);

    // Set to consented
    success = [manager setCurrentStatus:MPConsentStatusConsented reason:@"unit test" shouldBroadcast:YES];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);

    // Force explicit no
    [manager forceStatusShouldForceExplicitNo:YES
                      shouldInvalidateConsent:NO
                       shouldReacquireConsent:NO
                 shouldForceGDPRApplicability:NO
                          consentChangeReason:@"unit test"
                      shouldBroadcast:YES];

    // Assert that the consent status is denied
    XCTAssert(manager.currentStatus == MPConsentStatusDenied);
    XCTAssertNil(manager.consentedIabVendorList);
    XCTAssertNil(manager.consentedPrivacyPolicyVersion);
    XCTAssertNil(manager.consentedVendorListVersion);
}

- (void)testForceStatusForceConsentReset {
    NSDictionary * before = @{
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);

    // Set to consented
    success = [manager setCurrentStatus:MPConsentStatusConsented reason:@"unit test" shouldBroadcast:YES];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);

    // Force reacquire consent
    [manager forceStatusShouldForceExplicitNo:NO
                      shouldInvalidateConsent:YES
                       shouldReacquireConsent:NO
                 shouldForceGDPRApplicability:NO
                          consentChangeReason:@"unit test"
                      shouldBroadcast:YES];

    // Assert that the consent status is unknown
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);
    XCTAssertNil(manager.consentedIabVendorList);
    XCTAssertNil(manager.consentedPrivacyPolicyVersion);
    XCTAssertNil(manager.consentedVendorListVersion);
}

- (void)testForceStatusForceExplicitNoTakesPriorityOverConsentReset {
    NSDictionary * before = @{
                              @"is_whitelisted": @"0",
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);

    // Set to consented
    success = [manager setCurrentStatus:MPConsentStatusConsented reason:@"unit test" shouldBroadcast:YES];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusConsented);

    // Call forceStatus with both explicit no and reacquire consent
    [manager forceStatusShouldForceExplicitNo:YES
                      shouldInvalidateConsent:YES
                       shouldReacquireConsent:NO
                 shouldForceGDPRApplicability:NO
                          consentChangeReason:@"unit test"
                      shouldBroadcast:YES];

    // Assert that the consent status is denied
    XCTAssert(manager.currentStatus == MPConsentStatusDenied);
    XCTAssertNil(manager.consentedIabVendorList);
    XCTAssertNil(manager.consentedPrivacyPolicyVersion);
    XCTAssertNil(manager.consentedVendorListVersion);
}

- (void)testForceStatusForceDeniedFromUnknown {
    NSDictionary * before = @{
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);

    // Call forceStatus with both explicit no and reacquire consent
    [manager forceStatusShouldForceExplicitNo:YES
                      shouldInvalidateConsent:NO
                       shouldReacquireConsent:NO
                 shouldForceGDPRApplicability:NO
                          consentChangeReason:@"unit test"
                      shouldBroadcast:YES];

    // Assert that the consent status is denied
    XCTAssert(manager.currentStatus == MPConsentStatusDenied);
    XCTAssertNil(manager.consentedIabVendorList);
    XCTAssertNil(manager.consentedPrivacyPolicyVersion);
    XCTAssertNil(manager.consentedVendorListVersion);
}

- (void)testForceStatusForceUnknownFromDenied {
    NSDictionary * before = @{
                              @"is_whitelisted": @"0",
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
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);

    // Set to denied
    success = [manager setCurrentStatus:MPConsentStatusDenied reason:@"unit test" shouldBroadcast:YES];
    XCTAssertTrue(success);
    XCTAssert(manager.currentStatus == MPConsentStatusDenied);

    // Force reacquire consent
    [manager forceStatusShouldForceExplicitNo:NO
                      shouldInvalidateConsent:YES
                       shouldReacquireConsent:NO
                 shouldForceGDPRApplicability:NO
                          consentChangeReason:@"unit test"
                      shouldBroadcast:YES];

    // Assert that the consent status is unknown
    XCTAssert(manager.currentStatus == MPConsentStatusUnknown);
    XCTAssertNil(manager.consentedIabVendorList);
    XCTAssertNil(manager.consentedPrivacyPolicyVersion);
    XCTAssertNil(manager.consentedVendorListVersion);
}

#pragma mark - MPAdserverURLBuilder

- (void)testConsentSynchronizationUrlSuccess {
    MPConsentManager * manager = MPConsentManager.sharedManager;
    manager.adUnitIdUsedForConsent = @"abcdefg";

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);
}

- (void)testConsentSynchronizationUrlAfterTransitionSuccess {
    NSDictionary * before = @{
                              @"is_whitelisted": @"1",
                              @"is_gdpr_region": @"1",
                              @"call_again_after_secs": @"10",
                              @"current_privacy_policy_link": @"http://www.mopub.com/privacy",
                              @"current_privacy_policy_version": @"3.0.0",
                              @"current_vendor_list_link": @"http://www.mopub.com/vendors",
                              @"current_vendor_list_version": @"4.0.0",
                              @"current_vendor_list_iab_format": @"yyyyy",
                              @"current_vendor_list_iab_hash": @"hash",
                              @"extras": @"i'm extra!"
                              };

    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    manager.adUnitIdUsedForConsent = @"123456";
    BOOL success = [manager updateConsentStateWithParameters:before];
    XCTAssertTrue(success);

    // Grant consent
    [manager grantConsent];

    XCTAssert(manager.currentStatus == MPConsentStatusConsented);
    XCTAssert([manager.consentedIabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.consentedPrivacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.consentedVendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssertNotNil(manager.lastChangedReason);
    XCTAssertTrue(manager.isWhitelisted);
    XCTAssertTrue(manager.isGDPRApplicable == MPBoolYes);
    XCTAssert(manager.syncFrequency == 10);
    XCTAssert([manager.privacyPolicyUrl.absoluteString isEqualToString:@"http://www.mopub.com/privacy"]);
    XCTAssert([manager.privacyPolicyVersion isEqualToString:@"3.0.0"]);
    XCTAssert([manager.vendorListUrl.absoluteString isEqualToString:@"http://www.mopub.com/vendors"]);
    XCTAssert([manager.vendorListVersion isEqualToString:@"4.0.0"]);
    XCTAssert([manager.iabVendorList isEqualToString:@"yyyyy"]);
    XCTAssert([manager.iabVendorListHash isEqualToString:@"hash"]);

    // Generate the URL
    MPURL * syncUrl = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(syncUrl);

    // Validate the query parameters; really only care about the existence of the keys
    XCTAssert([[syncUrl stringForPOSTDataKey:kAdServerIDKey] isEqualToString:@"123456"]);
    XCTAssert([[syncUrl stringForPOSTDataKey:kCurrentConsentStatusKey] isEqualToString:@"explicit_yes"]);
    XCTAssertNotNil([syncUrl stringForPOSTDataKey:kLastChangedMsKey]);
    XCTAssertNotNil([syncUrl stringForPOSTDataKey:kSDKVersionKey]);
    XCTAssertNotNil([syncUrl stringForPOSTDataKey:kGDPRAppliesKey]);
    XCTAssertNotNil([syncUrl stringForPOSTDataKey:kConsentChangedReasonKey]);
    XCTAssert([[syncUrl stringForPOSTDataKey:kConsentedPrivacyPolicyVersionKey] isEqualToString:@"3.0.0"]);
    XCTAssert([[syncUrl stringForPOSTDataKey:kConsentedVendorListVersionKey] isEqualToString:@"4.0.0"]);
    XCTAssert([[syncUrl stringForPOSTDataKey:kCachedIabVendorListHashKey] isEqualToString:@"hash"]);
    XCTAssert([[syncUrl stringForPOSTDataKey:kExtrasKey] isEqualToString:@"i'm extra!"]);
}

#pragma mark - Macro Replacement

- (void)testValidPrivacyPolicyPreferredLanguageReplacement {
    NSDictionary * parameters = @{
                                  @"is_whitelisted": @"1",
                                  @"is_gdpr_region": @"1",
                                  @"call_again_after_secs": @"10",
                                  @"current_privacy_policy_link": @"http://www.mopub.com/privacy?lang=%%LANGUAGE%%",
                                  @"current_privacy_policy_version": @"3.0.0",
                                  @"current_vendor_list_link": @"http://www.mopub.com/vendors?lang=%%LANGUAGE%%",
                                  @"current_vendor_list_version": @"4.0.0",
                                  @"current_vendor_list_iab_format": @"yyyyy",
                                  @"current_vendor_list_iab_hash": @"hash",
                                  @"extras": @"i'm extra!",
                                  };

    // Update consent
    MPConsentManager * manager = MPConsentManager.sharedManager;
    BOOL success = [manager updateConsentStateWithParameters:parameters];
    XCTAssertTrue(success);

    // Validate privacy policy
    NSURL * privacyUrl = manager.privacyPolicyUrl;
    XCTAssertNotNil(privacyUrl);
    XCTAssert([privacyUrl.absoluteString isEqualToString:@"http://www.mopub.com/privacy?lang=en"]);

    // Validate vendor list
    NSURL * vendorListUrl = manager.vendorListUrl;
    XCTAssertNotNil(vendorListUrl);
    XCTAssert([vendorListUrl.absoluteString isEqualToString:@"http://www.mopub.com/vendors?lang=en"]);
}

- (void)testBadISOCodes {
    MPConsentManager * manager = MPConsentManager.sharedManager;
    NSURL * badf00d = [manager urlWithFormat:@"http://www.test.com?l=%%LANGUAGE%%" isoLanguageCode:nil];
    XCTAssertNil(badf00d);

    badf00d = [manager urlWithFormat:@"http://www.test.com?l=%%LANGUAGE%%" isoLanguageCode:@"france"];
    XCTAssertNil(badf00d);

    badf00d = [manager urlWithFormat:@"http://www.test.com?l=%%LANGUAGE%%" isoLanguageCode:@"FR"];
    XCTAssertNil(badf00d);
}

- (void)testGoodISOCodes {
    MPConsentManager * manager = MPConsentManager.sharedManager;
    NSURL * goodf00d = [manager urlWithFormat:@"http://www.test.com?l=%%LANGUAGE%%" isoLanguageCode:@"fr-Ch"];
    XCTAssertNotNil(goodf00d);
    XCTAssert([goodf00d.absoluteString isEqualToString:@"http://www.test.com?l=fr"]);
}

- (void)testOfficiallySupportedISOCodes {
    MPConsentManager * manager = MPConsentManager.sharedManager;
    NSString * urlFormat = @"http://www.test.com?l=%%LANGUAGE%%";
    NSString * expectedFormat = @"http://www.test.com?l=%@";
    NSArray<NSString *> * supportedCodes = @[@"en", @"fr", @"de", @"pt", @"it", @"es", @"nl"];

    for (NSString * isoCode in supportedCodes) {
        NSURL * url = [manager urlWithFormat:urlFormat isoLanguageCode:isoCode];
        NSString * expectedUrl = [NSString stringWithFormat:expectedFormat, isoCode];
        XCTAssertNotNil(url);
        XCTAssert([url.absoluteString isEqualToString:expectedUrl]);
    }
}

- (void)testStoreIfa {
    [MPConsentManager.sharedManager storeIfa];

    NSString *ifa = [NSUserDefaults.standardUserDefaults stringForKey:kIfaForConsentStorageKey];
    XCTAssertNotNil(ifa);
    [MPConsentManager.sharedManager removeIfa];
}

- (void)testRemoveIfa {
    [MPConsentManager.sharedManager storeIfa];
    [MPConsentManager.sharedManager removeIfa];
    NSString *ifa = [NSUserDefaults.standardUserDefaults stringForKey:kIfaForConsentStorageKey];
    XCTAssertNil(ifa);
}

- (void)testIfaOldStatusNotConsentedNewStatusNotConsented {
    [MPConsentManager.sharedManager setCurrentStatus:MPConsentStatusUnknown reason:@"Unit test: Consented" shouldBroadcast:YES];
    NSString *ifa = [NSUserDefaults.standardUserDefaults stringForKey:kIfaForConsentStorageKey];
    XCTAssertNil(ifa);
}

- (void)testIfaOldStatusNotConsentedNewStatusConsented {
    [MPConsentManager.sharedManager setCurrentStatus:MPConsentStatusUnknown reason:@"Unit test: Unknown" shouldBroadcast:YES];
    [MPConsentManager.sharedManager setCurrentStatus:MPConsentStatusConsented reason:@"Unit test: Consented" shouldBroadcast:YES];
    NSString *ifa = [NSUserDefaults.standardUserDefaults stringForKey:kIfaForConsentStorageKey];
    XCTAssertNotNil(ifa);
}

#pragma mark - Load Consent Dialog

- (void)testDialogWontLoadWithDNTOn {
    [MPConsentManager.sharedManager setCurrentStatus:MPConsentStatusDoNotTrack
                                              reason:@"Unit test: DNT"
                                     shouldBroadcast:YES];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for load to return"];
    __block NSError *loadError = nil;

    [MPConsentManager.sharedManager loadConsentDialogWithCompletion:^(NSError *error){
        loadError = error;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(loadError);
    XCTAssert(loadError.code == MPConsentErrorCodeLimitAdTrackingEnabled);
    XCTAssertFalse(MPConsentManager.sharedManager.isConsentDialogLoaded);
}

- (void)testDialogWontLoadIfGDPRDoesNotApply {
    [MPConsentManager.sharedManager setIsGDPRApplicable:MPBoolNo];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for load to return"];
    __block NSError *loadError = nil;

    [MPConsentManager.sharedManager loadConsentDialogWithCompletion:^(NSError *error){
        loadError = error;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(loadError);
    XCTAssert(loadError.code == MPConsentErrorCodeGDPRIsNotApplicable);
    XCTAssertFalse(MPConsentManager.sharedManager.isConsentDialogLoaded);
}

- (void)testDialogWontLoadIfNotSureIfGDPRApplies {
    [MPConsentManager.sharedManager setIsGDPRApplicable:MPBoolUnknown];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for load to return"];
    __block NSError *loadError = nil;

    [MPConsentManager.sharedManager loadConsentDialogWithCompletion:^(NSError *error){
        loadError = error;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(loadError);
    XCTAssert(loadError.code == MPConsentErrorCodeGDPRIsNotApplicable);
    XCTAssertFalse(MPConsentManager.sharedManager.isConsentDialogLoaded);
}

#pragma mark - Adunit ID Caching Mechanism

- (void)testAdunitIDNotOverwrittenIfAnotherIsCached {
    MPConsentManager * manager = MPConsentManager.sharedManager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    // Be sure the adunit ID is presently nil
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    NSString * cachedAdunitID = @"adunit ID";
    [NSUserDefaults.standardUserDefaults setObject:cachedAdunitID forKey:kAdUnitIdUsedForConsentStorageKey];

    // Check to make sure the cached value is returned
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:cachedAdunitID]);

    // Attempt to set a different adunit ID
    NSString * differentAdunitID = @"another adunit ID";
    manager.adUnitIdUsedForConsent = differentAdunitID;

    // Check to make sure the manager is still using the original adunit ID
    XCTAssertFalse([manager.adUnitIdUsedForConsent isEqualToString:differentAdunitID]);
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:cachedAdunitID]);
}

- (void)testIsKnownGoodWillCache {
    MPConsentManager * manager = MPConsentManager.sharedManager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    // Be sure the adunit ID is presently nil
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    // Make and set adunit ID as known good
    NSString * adunitID = @"adunit ID";
    [manager setAdUnitIdUsedForConsent:adunitID isKnownGood:YES];

    // Check to make sure the ID populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure it's cached
    XCTAssert([adunitID isEqualToString:[NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]]);
}

- (void)testIsNotKnownGoodWillNotCache {
    MPConsentManager * manager = MPConsentManager.sharedManager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    // Be sure the adunit ID is presently nil
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    // Make and set adunit ID
    NSString * adunitID = @"adunit ID";
    [manager setAdUnitIdUsedForConsent:adunitID isKnownGood:NO];

    // Check to make sure the ID populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure it's not cached
    XCTAssertNil([NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]);
}

- (void)testSettingDirectlyIsSameAsNotKnownGood {
    MPConsentManager * manager = MPConsentManager.sharedManager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    // Be sure the adunit ID is presently nil
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    // Make and set adunit ID
    NSString * adunitID = @"adunit ID";
    manager.adUnitIdUsedForConsent = adunitID;

    // Check to make sure the ID populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure it's not cached
    XCTAssertNil([NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]);
}

- (void)testSuccessfulSyncCachesAdunitID {
    MPConsentManager * manager = MPConsentManager.sharedManager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    // Be sure the adunit ID is presently nil
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    // Make and set adunit ID
    NSString * adunitID = @"adunit ID";
    manager.adUnitIdUsedForConsent = adunitID;

    // Check to make sure the ID populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure it's not yet cached
    XCTAssertNil([NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]);

    // Simulate successful sync
    [manager didFinishSynchronizationWithData:[NSData data]
                           synchronizedStatus:@""
                                   completion:^(NSError * error){}];

    // Check to make sure the ID is still populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure it is now cached
    XCTAssert([adunitID isEqualToString:[NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]]);
}

- (void)testUnsuccessfulSyncDoesNotCacheAdunitID {
    MPConsentManager * manager = MPConsentManager.sharedManager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    // Be sure the adunit ID is presently nil
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    // Make and set adunit ID
    NSString * adunitID = @"adunit ID";
    manager.adUnitIdUsedForConsent = adunitID;

    // Check to make sure the ID populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure it's not yet cached
    XCTAssertNil([NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]);

    // Simulate successful sync
    [manager didFailSynchronizationWithError:nil
                                  completion:^(NSError * error){}];

    // Check to make sure the ID is still populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure it is still not cached
    XCTAssertNil([NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]);
}

- (void)testSuccessfulSyncDoesNotOverwritePreviouslyCachedAdunitID {
    MPConsentManager * manager = MPConsentManager.sharedManager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    // Be sure the adunit ID is presently nil
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    // Cache an adunit ID
    NSString * cachedAdunitID = @"cached adunit ID";
    [manager setAdUnitIdUsedForConsent:cachedAdunitID isKnownGood:YES];

    // Make and set adunit ID
    NSString * adunitID = @"adunit ID";
    manager.adUnitIdUsedForConsent = adunitID;

    // Check to make sure the cached ID is populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:cachedAdunitID]);
    // Check to make sure it's cached
    XCTAssert([cachedAdunitID isEqualToString:[NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]]);

    // Simulate successful sync
    [manager didFinishSynchronizationWithData:[NSData data]
                           synchronizedStatus:@""
                                   completion:^(NSError * error){}];

    // Check to make sure the cached ID is populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:cachedAdunitID]);
    // Check to make sure it's cached
    XCTAssert([cachedAdunitID isEqualToString:[NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]]);
}

- (void)testCachedAdunitIDClears {
    /*
     Cache a new adunit ID
     */
    MPConsentManager * manager = MPConsentManager.sharedManager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an uninitialized state.
    manager.adUnitIdUsedForConsent = nil;
#pragma clang diagnostic pop
    // Be sure the adunit ID is presently nil
    XCTAssertNil(manager.adUnitIdUsedForConsent);

    // Make and set adunit ID
    NSString * adunitID = @"adunit ID";
    manager.adUnitIdUsedForConsent = adunitID;

    // Check to make sure the ID populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure it's not yet cached
    XCTAssertNil([NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]);

    // Simulate successful sync
    [manager didFinishSynchronizationWithData:[NSData data]
                           synchronizedStatus:@""
                                   completion:^(NSError * error){}];

    // Check to make sure the ID is still populated
    XCTAssert([manager.adUnitIdUsedForConsent isEqualToString:adunitID]);
    // Check to make sure it is now cached
    XCTAssert([adunitID isEqualToString:[NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]]);


    /*
     Clear the adunit ID and make sure it's totally cleared
     */
    [manager clearAdUnitIdUsedForConsent];
    XCTAssertNil(manager.adUnitIdUsedForConsent);
    XCTAssertNil([NSUserDefaults.standardUserDefaults stringForKey:kAdUnitIdUsedForConsentStorageKey]);
}

@end

