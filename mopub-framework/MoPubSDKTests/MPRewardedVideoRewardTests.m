//
//  MPRewardedVideoRewardTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPRewardedVideoReward.h"

@interface MPRewardedVideoRewardTests : XCTestCase

@end

@implementation MPRewardedVideoRewardTests

- (void)testUnicodeRewards {
    MPRewardedVideoReward * reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:@"🐱🌟" amount:@(100)];
    XCTAssertNotNil(reward);
}

@end
