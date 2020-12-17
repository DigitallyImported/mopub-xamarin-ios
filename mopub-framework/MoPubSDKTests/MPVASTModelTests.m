//
//  MPVASTModelTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTModel.h"

@interface MPVASTModelTests : XCTestCase

@end

@implementation MPVASTModelTests

- (void)testStringToURLMapperSuccess {
    MPNSStringToNSURLMapper * mapper = [[MPNSStringToNSURLMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"https://google.com"];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSURL class]]);
}

- (void)testStringToURLMapperWrongType {
    MPNSStringToNSURLMapper * mapper = [[MPNSStringToNSURLMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:[NSNull null]];

    XCTAssertNil(mappedValue);
}

- (void)testStringToNumberMapperSuccess {
    MPStringToNumberMapper * mapper = [[MPStringToNumberMapper alloc] initWithNumberStyle:NSNumberFormatterDecimalStyle];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"123"];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSNumber class]]);
    XCTAssert([mappedValue integerValue] == 123);
}

- (void)testStringToNumberMapperWrongType {
    MPStringToNumberMapper * mapper = [[MPStringToNumberMapper alloc] initWithNumberStyle:NSNumberFormatterDecimalStyle];
    id mappedValue = [mapper mappedObjectFromSourceObject:[NSNull null]];

    XCTAssertNil(mappedValue);
}

- (void)testClassMapperSuccess {
    MPClassMapper * mapper = [[MPClassMapper alloc] initWithDestinationClass:[MPVASTModel class]];
    id mappedValue = [mapper mappedObjectFromSourceObject:[NSDictionary dictionary]];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[MPVASTModel class]]);
}

- (void)testClassMapperWrongType {
    MPClassMapper * mapper = [[MPClassMapper alloc] initWithDestinationClass:[MPVASTModel class]];
    id mappedValue = [mapper mappedObjectFromSourceObject:[NSNull null]];

    XCTAssertNil(mappedValue);
}

- (void)testArrayMapperOneObjectSuccess {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:@"https://google.com"];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSArray class]]);
    XCTAssert([mappedValue count] == 1);
    XCTAssert([((NSURL *)mappedValue[0]) isEqual:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testArrayMapperMultiObjectSuccess {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:@[@"https://google.com", @"https://mopub.com"]];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSArray class]]);
    XCTAssert([mappedValue count] == 2);
    XCTAssert([((NSURL *)mappedValue[0]) isEqual:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([((NSURL *)mappedValue[1]) isEqual:[NSURL URLWithString:@"https://mopub.com"]]);
}

- (void)testArrayMapperOneObjectFailure {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:[NSNull null]];

    XCTAssertNil(mappedValue);
}

- (void)testArrayMapperMultiObjectHalfFailure {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:@[@"https://google.com", [NSNull null]]]; // included two objects, but expect one

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSArray class]]);
    XCTAssert([mappedValue count] == 1);
    XCTAssert([((NSURL *)mappedValue[0]) isEqual:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testArrayMapperMultiObjectFullFailure {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:@[[NSNull null], [NSNull null]]];

    XCTAssertNil(mappedValue);
}

@end
