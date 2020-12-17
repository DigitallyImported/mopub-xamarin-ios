//
//  MPNativeAdRequestTargetingTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPNativeAdRequestTargeting.h"

@interface MPNativeAdRequestTargetingTests : XCTestCase

@end

@implementation MPNativeAdRequestTargetingTests

- (void)testCreativeSafeSizeZero {
    MPNativeAdRequestTargeting * targeting = [MPNativeAdRequestTargeting targeting];
    XCTAssertNotNil(targeting);
    XCTAssert(CGSizeEqualToSize(targeting.creativeSafeSize, CGSizeZero));
}

@end
