//
//  MPConsentManager+Testing.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPConsentManager+Testing.h"

NSString * const kAdUnitIdUsedForConsentStorageKey               = @"com.mopub.mopub-ios-sdk.consent.ad.unit.id";
static NSString * const kConsentedIabVendorListStorageKey        = @"com.mopub.mopub-ios-sdk.consented.iab.vendor.list";
static NSString * const kConsentedPrivacyPolicyVersionStorageKey = @"com.mopub.mopub-ios-sdk.consented.privacy.policy.version";
static NSString * const kConsentedVendorListVersionStorageKey    = @"com.mopub.mopub-ios-sdk.consented.vendor.list.version";
static NSString * const kConsentStatusStorageKey                 = @"com.mopub.mopub-ios-sdk.consent.status";
static NSString * const kExtrasStorageKey                        = @"com.mopub.mopub-ios-sdk.extras";
static NSString * const kIabVendorListStorageKey                 = @"com.mopub.mopub-ios-sdk.iab.vendor.list";
static NSString * const kIabVendorListHashStorageKey             = @"com.mopub.mopub-ios-sdk.iab.vendor.list.hash";
NSString * const kIfaForConsentStorageKey                        = @"com.mopub.mopub-ios-sdk.ifa.for.consent";
static NSString * const kIsDoNotTrackStorageKey                  = @"com.mopub.mopub-ios-sdk.is.do.not.track";
static NSString * const kIsWhitelistedStorageKey                 = @"com.mopub.mopub-ios-sdk.is.whitelisted";
static NSString * const kGDPRAppliesStorageKey                   = @"com.mopub.mopub-ios-sdk.gdpr.applies";
static NSString * const kForceGDPRAppliesStorageKey              = @"com.mopub.mopub-ios-sdk.gdpr.force.applies.true";
static NSString * const kLastChangedMsStorageKey                 = @"com.mopub.mopub-ios-sdk.last.changed.ms";
static NSString * const kLastChangedReasonStorageKey             = @"com.mopub.mopub-ios-sdk.last.changed.reason";
static NSString * const kLastSynchronizedConsentStatusStorageKey = @"com.mopub.mopub-ios-sdk.last.synchronized.consent.status";
static NSString * const kPrivacyPolicyUrlStorageKey              = @"com.mopub.mopub-ios-sdk.privacy.policy.url";
static NSString * const kPrivacyPolicyVersionStorageKey          = @"com.mopub.mopub-ios-sdk.privacy.policy.version";
static NSString * const kShouldReacquireConsentStorageKey        = @"com.mopub.mopub-ios-sdk.should.reacquire.consent";
static NSString * const kVendorListUrlStorageKey                 = @"com.mopub.mopub-ios-sdk.vendor.list.url";
static NSString * const kVendorListVersionStorageKey             = @"com.mopub.mopub-ios-sdk.vendor.list.version";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@implementation MPConsentManager (Testing)

@dynamic rawIsGDPRApplicable;

// Override the default implementation to avoid the networking part of the code.
- (void)synchronizeConsentWithCompletion:(void (^ _Nonnull)(NSError * error))completion {
    completion(nil);
}

// Reset consent manager for testing
- (void)setUpConsentManagerForTesting {
    NSUserDefaults * defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:nil forKey:kAdUnitIdUsedForConsentStorageKey];
    [defaults setObject:nil forKey:kConsentedIabVendorListStorageKey];
    [defaults setObject:nil forKey:kConsentedPrivacyPolicyVersionStorageKey];
    [defaults setObject:nil forKey:kConsentedVendorListVersionStorageKey];
    [defaults setObject:nil forKey:kConsentStatusStorageKey];
    [defaults setInteger:MPBoolUnknown forKey:kGDPRAppliesStorageKey];
    [defaults setObject:nil forKey:kIfaForConsentStorageKey];
    [defaults setObject:nil forKey:kIsDoNotTrackStorageKey];
    [defaults setObject:nil forKey:kLastChangedMsStorageKey];
    [defaults setObject:nil forKey:kLastChangedReasonStorageKey];
    [defaults setObject:nil forKey:kShouldReacquireConsentStorageKey];
    [defaults setObject:nil forKey:kForceGDPRAppliesStorageKey];
}

- (void)setIsGDPRApplicable:(MPBool)isGDPRApplicable {
    [[NSUserDefaults standardUserDefaults] setInteger:isGDPRApplicable forKey:kGDPRAppliesStorageKey];
}

@end
#pragma clang diagnostic pop
