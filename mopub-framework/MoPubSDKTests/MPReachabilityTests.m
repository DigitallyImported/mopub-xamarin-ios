//
//  MPReachabilityTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPReachability.h"

NSUInteger const kTestIterations = 1000;

@interface MPReachabilityTests : XCTestCase

@end

@implementation MPReachabilityTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test100000CreationPerformance {
    // Measures the amount of time it takes to create an MPReachability
    // object on the fly and poll its current connection status for
    // kTestIterations iterations.
    [self measureBlock:^{
        for (NSUInteger index = 0; index < kTestIterations; index++) {
            // Use an autoreleasepool to make sure memory doesn't spike
            @autoreleasepool {
                MPReachability * reachability = [MPReachability reachabilityForInternetConnection];
                [reachability startNotifier];
                [reachability currentReachabilityStatus];
                [reachability stopNotifier];
            }
        }
    }];
}

- (void)test100000SingletonPerformance {
    MPReachability * reachability = [MPReachability reachabilityForInternetConnection];
    [reachability startNotifier];

    // Measures the amount of time it takes to query a "singleton" MPReachability
    // object about its current connection status for kTestIterations iterations.
    [self measureBlock:^{
        for (NSUInteger index = 0; index < kTestIterations; index++) {
            [reachability currentReachabilityStatus];
        }
    }];

    [reachability stopNotifier];
}

@end
