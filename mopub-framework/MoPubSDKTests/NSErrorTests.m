//
//  NSErrorTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "NSError+MPAdditions.h"

@interface NSErrorTests : XCTestCase

@end

@implementation NSErrorTests

#pragma mark - Status Codes

- (void)testNetworkErrorNegative200 {
    NSError * error = [NSError networkErrorWithHTTPStatusCode:-200];
    XCTAssertNotNil(error);
    XCTAssertNotNil(error.localizedDescription);
}

- (void)testNetworkErrorZero {
    NSError * error = [NSError networkErrorWithHTTPStatusCode:0];
    XCTAssertNotNil(error);
    XCTAssertNotNil(error.localizedDescription);
}

- (void)testNetworkError200 {
    NSError * error = [NSError networkErrorWithHTTPStatusCode:200];
    XCTAssertNotNil(error);
    XCTAssertNotNil(error.localizedDescription);
}

- (void)testNetworkError400 {
    NSError * error = [NSError networkErrorWithHTTPStatusCode:400];
    XCTAssertNotNil(error);
    XCTAssertNotNil(error.localizedDescription);
}

- (void)testNetworkError10000 {
    NSError * error = [NSError networkErrorWithHTTPStatusCode:10000];
    XCTAssertNotNil(error);
    XCTAssertNotNil(error.localizedDescription);
}

@end
