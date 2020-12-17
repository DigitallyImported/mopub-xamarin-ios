//
//  MPIdentityProviderTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPIdentityProvider.h"
#import "MPIdentityProvider+Testing.h"

// These should match the constants with the same name in `MPIdentityProvider.m`
#define MOPUB_IDENTIFIER_DEFAULTS_KEY      @"com.mopub.identifier"
#define MOPUB_IDENTIFIER_LAST_SET_TIME_KEY @"com.mopub.identifiertime"

@interface MPIdentityProviderTests : XCTestCase
@property (nonatomic, strong) NSCalendar * calendar;
@end

@implementation MPIdentityProviderTests

- (void)setUp {
    // Clear out the MoPub identifier
    [NSUserDefaults.standardUserDefaults removeObjectForKey:MOPUB_IDENTIFIER_DEFAULTS_KEY];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];
    [NSUserDefaults.standardUserDefaults synchronize];

    // Setup calendar
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    self.calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
}

#pragma mark - MoPub Identifier

- (void)testGenerateMoPubIdentifier {
    NSString * mopubId = [MPIdentityProvider mopubIdentifier:NO];
    XCTAssertNotNil(mopubId);
    XCTAssert([mopubId hasPrefix:@"mopub:"]);
    XCTAssertNotNil([NSUserDefaults.standardUserDefaults objectForKey:MOPUB_IDENTIFIER_DEFAULTS_KEY]);
    XCTAssertNotNil([NSUserDefaults.standardUserDefaults objectForKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY]);
}

- (void)testMoPubIdentifierSameUtcDay {
    NSString * mopubId = [MPIdentityProvider mopubIdentifier:NO];
    XCTAssertNotNil(mopubId);
    XCTAssert([mopubId hasPrefix:@"mopub:"]);
    XCTAssertNotNil([NSUserDefaults.standardUserDefaults objectForKey:MOPUB_IDENTIFIER_DEFAULTS_KEY]);
    XCTAssertNotNil([NSUserDefaults.standardUserDefaults objectForKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY]);

    NSString * secondTryMopubId = [MPIdentityProvider mopubIdentifier:NO];
    XCTAssertNotNil(secondTryMopubId);
    XCTAssert([secondTryMopubId hasPrefix:@"mopub:"]);
    XCTAssert([secondTryMopubId isEqualToString:mopubId]);
}

- (void)testMoPubIdentifierNextUtcDay {
    // Calculate previous UTC day
    NSDate * now = [NSDate date];
    NSDate * yesterday = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:now options:0];
    XCTAssert([now timeIntervalSinceDate:yesterday] > 0);

    // Set a fake mopub ID with yesterday's timestamp.
    NSString * const kFakeMoPubId = @"unittest:1234567890";
    [NSUserDefaults.standardUserDefaults setObject:kFakeMoPubId forKey:MOPUB_IDENTIFIER_DEFAULTS_KEY];
    [NSUserDefaults.standardUserDefaults setObject:yesterday forKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];
    [NSUserDefaults.standardUserDefaults synchronize];

    // Retrieve the MoPub identifier. This should trigger a new MoPub identifier generation.
    NSString * mopubId = [MPIdentityProvider mopubIdentifier:NO];
    XCTAssertNotNil(mopubId);
    XCTAssert([mopubId hasPrefix:@"mopub:"]);
    XCTAssert(![mopubId isEqualToString:kFakeMoPubId]);
    XCTAssertNotNil([NSUserDefaults.standardUserDefaults objectForKey:MOPUB_IDENTIFIER_DEFAULTS_KEY]);
    XCTAssertNotNil([NSUserDefaults.standardUserDefaults objectForKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY]);
}

- (void)testMoPubIdentifierNextUtcWeek {
    // Calculate previous UTC week
    NSDate * now = [NSDate date];
    NSDate * lastWeek = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:-7 toDate:now options:0];
    XCTAssert([now timeIntervalSinceDate:lastWeek] > 0);

    // Set a fake mopub ID with last week's timestamp.
    NSString * const kFakeMoPubId = @"unittest:1234567890";
    [NSUserDefaults.standardUserDefaults setObject:kFakeMoPubId forKey:MOPUB_IDENTIFIER_DEFAULTS_KEY];
    [NSUserDefaults.standardUserDefaults setObject:lastWeek forKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];
    [NSUserDefaults.standardUserDefaults synchronize];

    // Retrieve the MoPub identifier. This should trigger a new MoPub identifier generation.
    NSString * mopubId = [MPIdentityProvider mopubIdentifier:NO];
    XCTAssertNotNil(mopubId);
    XCTAssert([mopubId hasPrefix:@"mopub:"]);
    XCTAssert(![mopubId isEqualToString:kFakeMoPubId]);
    XCTAssertNotNil([NSUserDefaults.standardUserDefaults objectForKey:MOPUB_IDENTIFIER_DEFAULTS_KEY]);
    XCTAssertNotNil([NSUserDefaults.standardUserDefaults objectForKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY]);
}

@end
