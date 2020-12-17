//
//  MPHTTPNetworkSessionTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPHTTPNetworkSession.h"
#import "MPHTTPNetworkSession+Testing.h"
#import "NSURLSessionTask+Testing.h"

static NSString * const kTestURL = @"https://www.mopub.com";

@interface MPHTTPNetworkSessionTests : XCTestCase

@end

@implementation MPHTTPNetworkSessionTests

#pragma mark - Status Codes

- (void)testStatusCode200 {
    // Test URL
    NSURL * testURL = [NSURL URLWithString:kTestURL];

    // Fake request
    MPHTTPNetworkSession * session = MPHTTPNetworkSession.sharedInstance;
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:testURL];
    NSURLSessionDataTask * task = [session.sharedSession dataTaskWithRequest:request];

    // Fake response
    task.response = [[NSHTTPURLResponse alloc] initWithURL:testURL statusCode:200 HTTPVersion:nil headerFields:nil];

    // Setup handler
    __block BOOL didError = NO;
    MPHTTPNetworkTaskData * taskData = [[MPHTTPNetworkTaskData alloc] initWithResponseHandler:^(NSData * _Nonnull data, NSHTTPURLResponse * _Nonnull response) {
        didError = NO;
    } errorHandler:^(NSError * _Nonnull error) {
        didError = YES;
    } shouldRedirectWithNewRequest:^BOOL(NSURLSessionTask * _Nonnull task, NSURLRequest * _Nonnull newRequest) {
        return YES;
    }];

    // Fake response data
    taskData.responseData = [NSMutableData dataWithData:[kTestURL dataUsingEncoding:NSUTF8StringEncoding]];

    // Fake network completion
    [session setSessionData:taskData forTask:task];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull" // intentional nil test
    [session URLSession:nil task:task didCompleteWithError:nil];
#pragma clang diagnostic push

    XCTAssertFalse(didError);
}

- (void)testStatusCode302 {
    // Test URL
    NSURL * testURL = [NSURL URLWithString:kTestURL];

    // Fake request
    MPHTTPNetworkSession * session = MPHTTPNetworkSession.sharedInstance;
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:testURL];
    NSURLSessionDataTask * task = [session.sharedSession dataTaskWithRequest:request];

    // Fake response
    task.response = [[NSHTTPURLResponse alloc] initWithURL:testURL statusCode:302 HTTPVersion:nil headerFields:nil];

    // Setup handler
    __block BOOL didError = NO;
    MPHTTPNetworkTaskData * taskData = [[MPHTTPNetworkTaskData alloc] initWithResponseHandler:^(NSData * _Nonnull data, NSHTTPURLResponse * _Nonnull response) {
        didError = NO;
    } errorHandler:^(NSError * _Nonnull error) {
        didError = YES;
    } shouldRedirectWithNewRequest:^BOOL(NSURLSessionTask * _Nonnull task, NSURLRequest * _Nonnull newRequest) {
        return YES;
    }];

    // Fake response data
    taskData.responseData = [NSMutableData dataWithData:[kTestURL dataUsingEncoding:NSUTF8StringEncoding]];

    // Fake network completion
    [session setSessionData:taskData forTask:task];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull" // intentional nil test
    [session URLSession:nil task:task didCompleteWithError:nil];
#pragma clang diagnostic pop

    XCTAssertFalse(didError);
}

- (void)testStatusCode400Fail {
    // Test URL
    NSURL * testURL = [NSURL URLWithString:kTestURL];

    // Fake request
    MPHTTPNetworkSession * session = MPHTTPNetworkSession.sharedInstance;
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:testURL];
    NSURLSessionDataTask * task = [session.sharedSession dataTaskWithRequest:request];

    // Fake response
    task.response = [[NSHTTPURLResponse alloc] initWithURL:testURL statusCode:400 HTTPVersion:nil headerFields:nil];

    // Setup handler
    __block BOOL didError = NO;
    MPHTTPNetworkTaskData * taskData = [[MPHTTPNetworkTaskData alloc] initWithResponseHandler:^(NSData * _Nonnull data, NSHTTPURLResponse * _Nonnull response) {
        didError = NO;
    } errorHandler:^(NSError * _Nonnull error) {
        didError = YES;
    } shouldRedirectWithNewRequest:^BOOL(NSURLSessionTask * _Nonnull task, NSURLRequest * _Nonnull newRequest) {
        return YES;
    }];

    // Fake response data
    taskData.responseData = [NSMutableData dataWithData:[kTestURL dataUsingEncoding:NSUTF8StringEncoding]];

    // Fake network completion
    [session setSessionData:taskData forTask:task];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull" // intentional nil test
    [session URLSession:nil task:task didCompleteWithError:nil];
#pragma clang diagnostic pop

    XCTAssertTrue(didError);
}

- (void)testStatusCode500Fail {
    // Test URL
    NSURL * testURL = [NSURL URLWithString:kTestURL];

    // Fake request
    MPHTTPNetworkSession * session = MPHTTPNetworkSession.sharedInstance;
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:testURL];
    NSURLSessionDataTask * task = [session.sharedSession dataTaskWithRequest:request];

    // Fake response
    task.response = [[NSHTTPURLResponse alloc] initWithURL:testURL statusCode:500 HTTPVersion:nil headerFields:nil];

    // Setup handler
    __block BOOL didError = NO;
    MPHTTPNetworkTaskData * taskData = [[MPHTTPNetworkTaskData alloc] initWithResponseHandler:^(NSData * _Nonnull data, NSHTTPURLResponse * _Nonnull response) {
        didError = NO;
    } errorHandler:^(NSError * _Nonnull error) {
        didError = YES;
    } shouldRedirectWithNewRequest:^BOOL(NSURLSessionTask * _Nonnull task, NSURLRequest * _Nonnull newRequest) {
        return YES;
    }];

    // Fake response data
    taskData.responseData = [NSMutableData dataWithData:[kTestURL dataUsingEncoding:NSUTF8StringEncoding]];

    // Fake network completion
    [session setSessionData:taskData forTask:task];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull" // intentional nil test
    [session URLSession:nil task:task didCompleteWithError:nil];
#pragma clang diagnostic pop

    XCTAssertTrue(didError);
}

#pragma mark - Thread Safety

- (void)testThreadSafeSessionAccess {
    MPHTTPNetworkSession * session = MPHTTPNetworkSession.sharedInstance;
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.mopub.com"]];
    NSURLSessionDataTask * task = [session.sharedSession dataTaskWithRequest:request];
    MPHTTPNetworkTaskData * taskData = [[MPHTTPNetworkTaskData alloc] initWithResponseHandler:nil errorHandler:nil shouldRedirectWithNewRequest:nil];

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for concurrency test to finish"];
    dispatch_group_t testsGroup = dispatch_group_create();
    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [session setSessionData:taskData forTask:task];
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        MPHTTPNetworkTaskData * data = [session sessionDataForTask:task];
        data.responseData = [NSMutableData new];
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (int i = 0 ; i < 1000; i++) {
            NSString * testString = @"i'm a test";
            NSData * newData = [testString dataUsingEncoding:NSUTF8StringEncoding];

            [session appendData:newData toSessionDataForTask:task];
        }
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (int i = 0 ; i < 1000; i++) {
            NSString * testString = @"poop";
            NSData * newData = [testString dataUsingEncoding:NSUTF8StringEncoding];

            [session appendData:newData toSessionDataForTask:task];
        }
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        MPHTTPNetworkTaskData * data2 = [session sessionDataForTask:task];
        data2.responseData = [NSMutableData new];
    });

    dispatch_group_notify(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
