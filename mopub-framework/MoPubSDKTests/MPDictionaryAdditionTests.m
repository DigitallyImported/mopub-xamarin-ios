//
//  MPDictionaryAdditionTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "NSDictionary+MPAdditions.h"

static const float kVisibleShift = 0.00000001;

NSString * const kMPDictionaryAdditionTestKey = @"kMPDictionaryAdditionTestKey";

@interface MPDictionaryAdditionTests : XCTestCase

@end

@implementation MPDictionaryAdditionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIntegerWhenInputIsInvalid {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"aaa"};
    NSInteger value = [dict mp_integerForKey:kMPDictionaryAdditionTestKey];
    XCTAssertEqual(value, 0);
}

- (void)testIntegerWhenInputIsValidString {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"12"};
    NSInteger value = [dict mp_integerForKey:kMPDictionaryAdditionTestKey];
    XCTAssertEqual(value, 12);
}

- (void)testIntegerWhenInputIsValidNumber {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @(12)};
    NSInteger value = [dict mp_integerForKey:kMPDictionaryAdditionTestKey];
    XCTAssertEqual(value, 12);
}

- (void)testIntegerWhenInputIsStringZero {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"0"};
    NSInteger value = [dict mp_integerForKey:kMPDictionaryAdditionTestKey];
    XCTAssertEqual(value, 0);
}

- (void)testIntegerWhenInputIsNumberZero {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @(0)};
    NSInteger value = [dict mp_integerForKey:kMPDictionaryAdditionTestKey];
    XCTAssertEqual(value, 0);
}

- (void)testDoubleWhenInputIsInvalid {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"aaa"};
    double value = [dict mp_doubleForKey:kMPDictionaryAdditionTestKey];
    XCTAssertEqual(value, 0);
}

- (void)testDoubleWhenInputIsValidString {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"12.1"};
    double value = [dict mp_doubleForKey:kMPDictionaryAdditionTestKey];
    XCTAssertEqual(value, 12.1);
}

- (void)testDoubleWhenInputIsValidNumber {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @(12.1)};
    double value = [dict mp_doubleForKey:kMPDictionaryAdditionTestKey];
    XCTAssertEqual(value, 12.1);
}

- (void)testDoubleWhenInputIsStringZero {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"0.0"};
    double value = [dict mp_integerForKey:kMPDictionaryAdditionTestKey];
    XCTAssertEqual(value, 0);
}

- (void)testDoubleWhenInputIsNumberZero {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @(0.0)};
    double value = [dict mp_integerForKey:kMPDictionaryAdditionTestKey];
    XCTAssertEqual(value, 0);
}

- (void)testStringIsEmpty {
    NSString *str = @"";
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: str};
    XCTAssertEqual([dict mp_stringForKey:kMPDictionaryAdditionTestKey], str);
}

- (void)testStringValidInput {
    NSString *str = @"test string";
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: str};
    XCTAssertEqual([dict mp_stringForKey:kMPDictionaryAdditionTestKey], str);
}

- (void)testBoolWhenInputIsInvalid {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"aaa"};
    double value = [dict mp_boolForKey:kMPDictionaryAdditionTestKey];
    XCTAssertFalse(value);
}

- (void)testBoolWhenInputIsTrue {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"1"};
    double value = [dict mp_boolForKey:kMPDictionaryAdditionTestKey];
    XCTAssertTrue(value);
}

- (void)testBoolWhenInputIsFalse {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"0"};
    double value = [dict mp_boolForKey:kMPDictionaryAdditionTestKey];
    XCTAssertFalse(value);
}

- (void)testFloatWhenInputIsValidString {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"12.1"};
    float value = [dict mp_floatForKey:kMPDictionaryAdditionTestKey];
    XCTAssertTrue([self floatEquals:value secondNum:12.1]);
}

- (void)testFloatWhenInputIsValidNumber {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @(12.1)};
    float value = [dict mp_floatForKey:kMPDictionaryAdditionTestKey];
    XCTAssertTrue([self floatEquals:value secondNum:12.1]);
}

- (void)testFloatWhenInputIsStringZero {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @"0.0"};
    float value = [dict mp_floatForKey:kMPDictionaryAdditionTestKey];
    XCTAssertTrue([self floatEquals:value secondNum:0]);
}

- (void)testFloatWhenInputIsNumberZero {
    NSDictionary *dict = @{kMPDictionaryAdditionTestKey: @(0.0)};
    float value = [dict mp_floatForKey:kMPDictionaryAdditionTestKey];
    XCTAssertTrue([self floatEquals:value secondNum:0]);
}

- (BOOL)floatEquals:(float)firstNum secondNum:(float)secondNum {
    if ((firstNum - secondNum) < fabs(kVisibleShift)) {
        return YES;
    }
    return NO;

}

@end
