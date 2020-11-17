//
//  MPURLRequestTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAPIEndpoints.h"
#import "MPURL.h"
#import "MPURLRequest+Testing.h"

@interface MPURLRequestTests : XCTestCase

@end

@implementation MPURLRequestTests

#pragma mark - JSON Building

- (void)testPOSTDataSuccessful {
    NSDictionary * postData = @{
                                @"string": @"1",
                                @"number": @(2),
                                @"sentence": @"i am a cat meow",
                                @"unencoded": @"!#$&'()*+,/:;=?@[]",
                                @"encoded": @"i%20am%20a%20cat%20meow",
                                @"array": @[@"one", @"two"],
                                @"dictionary": @{ @"token": @"1" },
                                };

    MPURL * url = [MPURL URLWithString:@"https://www.test.com/t1?a=1&b=2"];
    [url.postData addEntriesFromDictionary:postData];
    XCTAssertNotNil(url);

    MPURLRequest * request = [MPURLRequest requestWithURL:url];
    XCTAssertNotNil(request);

    NSData * data = request.HTTPBody;
    XCTAssertNotNil(data);

    NSError * error = nil;
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    XCTAssertNotNil(json);
    XCTAssert(json.count > 0);

    XCTAssert([json[@"string"] isEqualToString:@"1"]);
    XCTAssert([json[@"number"] intValue] == 2);
    XCTAssert([json[@"sentence"] isEqualToString:@"i am a cat meow"]);
    XCTAssert([json[@"unencoded"] isEqualToString:@"!#$&'()*+,/:;=?@[]"]);
    XCTAssert([json[@"encoded"] isEqualToString:@"i%20am%20a%20cat%20meow"]);

    NSArray * array = json[@"array"];
    XCTAssertNotNil(array);
    XCTAssert(array.count == 2);
    XCTAssert([array.firstObject isEqualToString:@"one"]);
    XCTAssert([array.lastObject isEqualToString:@"two"]);

    NSDictionary * dict = json[@"dictionary"];
    XCTAssertNotNil(dict);
    XCTAssert([dict[@"token"] isEqualToString:@"1"]);
}

- (void)testBadPOSTDataGeneratesNoPOSTBody {
    NSDictionary * postData = @{ @"time": NSDate.date };

    MPURL * url = [MPURL URLWithString:@"https://www.test.com/t1?a=1&b=2"];
    [url.postData addEntriesFromDictionary:postData];
    XCTAssertNotNil(url);

    MPURLRequest * request = [MPURLRequest requestWithURL:url];
    XCTAssertNil(request.HTTPBody);
}

- (void)testMoPubHostNoPOSTData {
    NSString * mopubUrl = [NSString stringWithFormat:@"https://%@", [MPAPIEndpoints baseHostname]];
    MPURL * url = [[MPURL alloc] initWithString:mopubUrl];
    XCTAssertNotNil(url);

    MPURLRequest * request = [MPURLRequest requestWithURL:url];
    XCTAssertNotNil(request.HTTPBody);
}

- (void)testNotMoPubHostWithPOSTData {
    NSString * unitTestUrl = @"https://www.unittest.com";
    MPURL * url = [MPURL URLWithString:unitTestUrl];
    XCTAssertNotNil(url);

    url.postData[@"q"] = @"i'm a cat!";
    XCTAssert(url.postData.count == 1);

    MPURLRequest * request = [MPURLRequest requestWithURL:url];
    XCTAssertNotNil(request.HTTPBody);

    NSError * error = nil;
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:&error];
    XCTAssertNotNil(json);
    XCTAssert(json.count > 0);

    XCTAssert([json[@"q"] isEqualToString:@"i'm a cat!"]);
}

- (void)testCombineQueryParametersWithPOSTDataForMoPubHost {
    NSString * unitTestUrl = @"https://ads.mopub.com/combine?q=i%20am%20a%20cat%20meow&k=%21%23%24%26%27%28%29%2A%2B%2C%2F%3A%3B%3D%3F%40%5B%5D";
    MPURL * url = [MPURL URLWithString:unitTestUrl];
    XCTAssertNotNil(url);

    url.postData[@"query2"] = @(77);
    XCTAssert(url.postData.count == 1);

    MPURLRequest * request = [MPURLRequest requestWithURL:url];
    XCTAssertNotNil(request.HTTPBody);

    NSError * error = nil;
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:&error];
    XCTAssertNotNil(json);
    XCTAssert(json.count == 3);

    XCTAssert([json[@"q"] isEqualToString:@"i am a cat meow"]);
    XCTAssert([json[@"k"] isEqualToString:@"!#$&'()*+,/:;=?@[]"]);
    XCTAssert([json[@"query2"] intValue] == 77);
}

- (void)testDoNotCombineQueryParametersWithPOSTDataForOtherHost {
    NSString * unitTestUrl = @"https://www.unittest.com/combine?q=i%20am%20a%20cat%20meow&k=%21%23%24%26%27%28%29%2A%2B%2C%2F%3A%3B%3D%3F%40%5B%5D";
    MPURL * url = [MPURL URLWithString:unitTestUrl];
    XCTAssertNotNil(url);

    url.postData[@"query2"] = @(77);
    XCTAssert(url.postData.count == 1);

    MPURLRequest * request = [MPURLRequest requestWithURL:url];
    XCTAssertNotNil(request.HTTPBody);

    NSError * error = nil;
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:&error];
    XCTAssertNotNil(json);
    XCTAssert(json.count == 1);
    XCTAssert([json[@"query2"] intValue] == 77);
}

- (void)testUserAgentCanBeObtainedOnNonMainThread {
    // reset user agent so MPURLRequest has to reobtain it
    gUserAgent = nil;

    dispatch_queue_t nonMainQueue = dispatch_queue_create("test queue", NULL);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for user agent to fill on background thread"];

    // This will crash if the user agent isn't obtained via the main thread.
    __block NSString * userAgent = nil;
    dispatch_async(nonMainQueue, ^{
        userAgent = [MPURLRequest userAgent];
        [expectation fulfill];
    });

    [self waitForExpectations:@[expectation] timeout:5.0];

    XCTAssertNotNil(userAgent);
}

- (void)testUserAgentCanBeObtainedOnMainThread {
    // reset user agent so MPURLRequest has to reobtain it
    gUserAgent = nil;

    NSString * userAgent = [MPURLRequest userAgent];

    XCTAssertNotNil(userAgent);
}

- (void)testUserAgentCanBeObtainedOnMainQueue {
    // reset user agent so MPURLRequest has to reobtain it
    gUserAgent = nil;

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for user agent to fill on background thread"];

    __block NSString * userAgent = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        userAgent = [MPURLRequest userAgent];
        [expectation fulfill];
    });

    [self waitForExpectations:@[expectation] timeout:5.0];

    XCTAssertNotNil(userAgent);
}

- (void)testJSONNotPrettyPrinted {
    NSDictionary * postData = @{ @"string": @"1" };
    NSString * const exptectedJSON = @"{\"string\":\"1\"}";

    MPURL * url = [MPURL URLWithString:@"https://www.test.com"];
    [url.postData addEntriesFromDictionary:postData];
    XCTAssertNotNil(url);

    MPURLRequest * request = [MPURLRequest requestWithURL:url];
    XCTAssertNotNil(request);

    NSData * data = request.HTTPBody;
    XCTAssertNotNil(data);

    NSString * jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(jsonString);
    XCTAssert([jsonString isEqualToString:exptectedJSON]);
}

@end
