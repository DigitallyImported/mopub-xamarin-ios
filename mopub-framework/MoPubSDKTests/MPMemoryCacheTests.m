//
//  MPMemoryCacheTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPMemoryCache.h"

@interface MPMemoryCacheTests : XCTestCase

@end

@implementation MPMemoryCacheTests

#pragma mark - Thread Safety

- (void)testThreadSafeSessionAccess {
    NSString * const kUnitTestKey = @"unittesting";
    __block NSUInteger count = 0;

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for concurrency test to finish"];
    dispatch_group_t testsGroup = dispatch_group_create();
    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData * data = [NSData new];
        [MPMemoryCache.sharedInstance setData:data forKey:kUnitTestKey];
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Reading
        for (int i = 0 ; i < 1000; i++) {
            NSData * data = [MPMemoryCache.sharedInstance dataForKey:kUnitTestKey];
            NSString * base64 = [data base64EncodedStringWithOptions:0];
            if (base64.length > 0) {
                count++;
            }
        }
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Writing
        for (int i = 0 ; i < 1000; i++) {
            NSString * testString = @"i'm a test";
            NSData * newData = [testString dataUsingEncoding:NSUTF8StringEncoding];

            NSMutableData * data = [[MPMemoryCache.sharedInstance dataForKey:kUnitTestKey] mutableCopy];
            [data appendData:newData];

            [MPMemoryCache.sharedInstance setData:data forKey:kUnitTestKey];
        }
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Writing
        for (int i = 0 ; i < 1000; i++) {
            NSString * testString = @"poop";
            NSData * newData = [testString dataUsingEncoding:NSUTF8StringEncoding];

            NSMutableData * data = [[MPMemoryCache.sharedInstance dataForKey:kUnitTestKey] mutableCopy];
            [data appendData:newData];

            [MPMemoryCache.sharedInstance setData:data forKey:kUnitTestKey];
        }
    });

    dispatch_group_notify(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
