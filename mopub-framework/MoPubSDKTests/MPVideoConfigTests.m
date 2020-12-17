//
//  MPVideoConfigTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "XCTestCase+MPAddition.h"
#import "MPVASTManager.h"
#import "MPVASTResponse.h"
#import "MPVideoConfig.h"
#import "MPVASTTrackingEvent.h"

static const NSTimeInterval kDefaultTimeout   = 1;

static NSString * const kTrackerEventDictionaryKey = @"event";
static NSString * const kTrackerTextDictionaryKey = @"text";
static NSString * const kFirstAdditionalStartTrackerUrl = @"mopub.com/start1";
static NSString * const kFirstAdditionalFirstQuartileTrackerUrl = @"mopub.com/firstQuartile1";
static NSString * const kFirstAdditionalMidpointTrackerUrl = @"mopub.com/midpoint1";
static NSString * const kFirstAdditionalThirdQuartileTrackerUrl = @"mopub.com/thirdQuartile1";
static NSString * const kFirstAdditionalCompleteTrackerUrl = @"mopub.com/complete1";

static NSString * const kSecondAdditionalStartTrackerUrl = @"mopub.com/start2";
static NSString * const kSecondAdditionalFirstQuartileTrackerUrl = @"mopub.com/firstQuartile2";
static NSString * const kSecondAdditionalMidpointTrackerUrl = @"mopub.com/midpoint2";
static NSString * const kSecondAdditionalThirdQuartileTrackerUrl = @"mopub.com/thirdQuartile2";
static NSString * const kSecondAdditionalCompleteTrackerUrl = @"mopub.com/complete2";

@interface MPVideoConfigTests : XCTestCase

@end

@implementation MPVideoConfigTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Test when vast doesn't have any trackers and addtionalTrackers don't have any trackers either.
- (void)testEmptyVastEmptyAdditionalTrackers {
    // vast response is nil
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:nil additionalTrackers:nil];
    XCTAssertEqual(videoConfig.startTrackers.count, 0);
    XCTAssertEqual(videoConfig.firstQuartileTrackers.count, 0);
    XCTAssertEqual(videoConfig.midpointTrackers.count, 0);
    XCTAssertEqual(videoConfig.thirdQuartileTrackers.count, 0);
    XCTAssertEqual(videoConfig.completionTrackers.count, 0);

    // vast response is not nil, but it doesn't have trackers.
    MPVideoConfig *videoConfig2 = [[MPVideoConfig alloc] initWithVASTResponse:[MPVASTResponse new] additionalTrackers:nil];
    XCTAssertEqual(videoConfig2.startTrackers.count, 0);
    XCTAssertEqual(videoConfig2.firstQuartileTrackers.count, 0);
    XCTAssertEqual(videoConfig2.midpointTrackers.count, 0);
    XCTAssertEqual(videoConfig2.thirdQuartileTrackers.count, 0);
    XCTAssertEqual(videoConfig2.completionTrackers.count, 0);
}

// Test when there are trackers in vast but no trackers in additonalTrackers. This test also ensures that trackers with no URLs are not included in the video config
- (void)testNonEmptyVastEmptyAdditionalTrackers {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for fetching data from xml."];

    __block NSData *vastData = [self dataFromXMLFileNamed:@"linear-tracking" class:[self class]];
    __block MPVASTResponse *vastResponse;
    [MPVASTManager fetchVASTWithData:vastData completion:^(MPVASTResponse *response, NSError *error) {
        XCTAssertNil(error);
        vastResponse = response;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    // linear-tracking.xml has 1 for each of the following trackers: start, firstQuartile, midpoint, thirdQuartile, and complete.
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertEqual(videoConfig.creativeViewTrackers.count, 1);
    XCTAssertEqual(videoConfig.startTrackers.count, 1);
    XCTAssertEqual(videoConfig.firstQuartileTrackers.count, 1);
    XCTAssertEqual(videoConfig.midpointTrackers.count, 1);
    XCTAssertEqual(videoConfig.thirdQuartileTrackers.count, 1);
    XCTAssertEqual(videoConfig.completionTrackers.count, 1);

    // additionalTrackers are not nil but there is nothing inside
    MPVideoConfig *videoConfig2 = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:[NSDictionary new]];
    XCTAssertEqual(videoConfig.creativeViewTrackers.count, 1);
    XCTAssertEqual(videoConfig2.startTrackers.count, 1);
    XCTAssertEqual(videoConfig2.firstQuartileTrackers.count, 1);
    XCTAssertEqual(videoConfig2.midpointTrackers.count, 1);
    XCTAssertEqual(videoConfig2.thirdQuartileTrackers.count, 1);
    XCTAssertEqual(videoConfig2.completionTrackers.count, 1);
}

// Test when VAST doesn't have any trackers and there is exactly one entry for each event type
- (void)testSingleTrackeForEachEventInAdditionalTrackers {
    // set up VAST response
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for fetching data from xml."];
    __block NSData *vastData = [self dataFromXMLFileNamed:@"linear-tracking-no-event" class:[self class]];
    __block MPVASTResponse *vastResponse;
    [MPVASTManager fetchVASTWithData:vastData completion:^(MPVASTResponse *response, NSError *error) {
        XCTAssertNil(error);
        vastResponse = response;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];


    NSDictionary *additonalTrackersDict = [self getAdditionalTrackersWithOneEntryForEachEvent];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:additonalTrackersDict];
    XCTAssertEqual(videoConfig.startTrackers.count, 1);
    XCTAssertEqual(videoConfig.firstQuartileTrackers.count, 1);
    XCTAssertEqual(videoConfig.midpointTrackers.count, 1);
    XCTAssertEqual(videoConfig.thirdQuartileTrackers.count, 1);
    XCTAssertEqual(videoConfig.completionTrackers.count, 1);

    // verify type and url
    XCTAssertEqual(((MPVASTTrackingEvent *)videoConfig.startTrackers.firstObject).eventType, MPVASTTrackingEventTypeStart);
    XCTAssertEqualObjects(((MPVASTTrackingEvent *)videoConfig.startTrackers.firstObject).URL, [NSURL URLWithString:kFirstAdditionalStartTrackerUrl]);

    XCTAssertEqual(((MPVASTTrackingEvent *)videoConfig.firstQuartileTrackers.firstObject).eventType, MPVASTTrackingEventTypeFirstQuartile);
    XCTAssertEqualObjects(((MPVASTTrackingEvent *)videoConfig.firstQuartileTrackers.firstObject).URL, [NSURL URLWithString:kFirstAdditionalFirstQuartileTrackerUrl]);

    XCTAssertEqual(((MPVASTTrackingEvent *)videoConfig.midpointTrackers.firstObject).eventType, MPVASTTrackingEventTypeMidpoint);
    XCTAssertEqualObjects(((MPVASTTrackingEvent *)videoConfig.midpointTrackers.firstObject).URL, [NSURL URLWithString:kFirstAdditionalMidpointTrackerUrl]);

    XCTAssertEqual(((MPVASTTrackingEvent *)videoConfig.thirdQuartileTrackers.firstObject).eventType, MPVASTTrackingEventTypeThirdQuartile);
    XCTAssertEqualObjects(((MPVASTTrackingEvent *)videoConfig.thirdQuartileTrackers.firstObject).URL, [NSURL URLWithString:kFirstAdditionalThirdQuartileTrackerUrl]);

    XCTAssertEqual(((MPVASTTrackingEvent *)videoConfig.completionTrackers.firstObject).eventType, MPVASTTrackingEventTypeComplete);
    XCTAssertEqualObjects(((MPVASTTrackingEvent *)videoConfig.completionTrackers.firstObject).URL, [NSURL URLWithString:kFirstAdditionalCompleteTrackerUrl]);
}

- (void)testMergeTrackers {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for fetching data from xml."];

    __block NSData *vastData = [self dataFromXMLFileNamed:@"linear-tracking" class:[self class]];
    __block MPVASTResponse *vastResponse;
    [MPVASTManager fetchVASTWithData:vastData completion:^(MPVASTResponse *response, NSError *error) {
        XCTAssertNil(error);
        vastResponse = response;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    NSDictionary *additonalTrackersDict = [self getAdditionalTrackersWithTwoEntriesForEachEvent];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:additonalTrackersDict];
    // one tracker from vast, two from additonalTrackers
    XCTAssertEqual(videoConfig.startTrackers.count, 3);
    XCTAssertEqual(videoConfig.firstQuartileTrackers.count, 3);
    XCTAssertEqual(videoConfig.midpointTrackers.count, 3);
    XCTAssertEqual(videoConfig.thirdQuartileTrackers.count, 3);
    XCTAssertEqual(videoConfig.completionTrackers.count, 3);
}

- (NSDictionary *)getAdditionalTrackersWithOneEntryForEachEvent
{
    NSMutableDictionary *addtionalTrackersDict = [NSMutableDictionary new];
    NSDictionary *startTrackerDict = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeStart, kTrackerTextDictionaryKey:kFirstAdditionalStartTrackerUrl};
    MPVASTTrackingEvent *startTracker = [[MPVASTTrackingEvent alloc] initWithDictionary:startTrackerDict];

    NSDictionary *firstQuartileTrackerDict = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeFirstQuartile, kTrackerTextDictionaryKey:kFirstAdditionalFirstQuartileTrackerUrl};
    MPVASTTrackingEvent *firstQuartileTracker = [[MPVASTTrackingEvent alloc] initWithDictionary:firstQuartileTrackerDict];

    NSDictionary *midpointTrackerDict = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeMidpoint, kTrackerTextDictionaryKey:kFirstAdditionalMidpointTrackerUrl};
    MPVASTTrackingEvent *midpointTracker = [[MPVASTTrackingEvent alloc] initWithDictionary:midpointTrackerDict];

    NSDictionary *thirdQuartileTrackerDict = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeThirdQuartile, kTrackerTextDictionaryKey:kFirstAdditionalThirdQuartileTrackerUrl};
    MPVASTTrackingEvent *thirdQuartileTracker = [[MPVASTTrackingEvent alloc] initWithDictionary:thirdQuartileTrackerDict];

    NSDictionary *completeTrackerDict = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeComplete, kTrackerTextDictionaryKey:kFirstAdditionalCompleteTrackerUrl};
    MPVASTTrackingEvent *completeTracker = [[MPVASTTrackingEvent alloc] initWithDictionary:completeTrackerDict];

    addtionalTrackersDict[MPVASTTrackingEventTypeStart] = @[startTracker];
    addtionalTrackersDict[MPVASTTrackingEventTypeFirstQuartile] = @[firstQuartileTracker];
    addtionalTrackersDict[MPVASTTrackingEventTypeMidpoint] = @[midpointTracker];
    addtionalTrackersDict[MPVASTTrackingEventTypeThirdQuartile] = @[thirdQuartileTracker];
    addtionalTrackersDict[MPVASTTrackingEventTypeComplete] = @[completeTracker];

    return addtionalTrackersDict;
}

- (NSDictionary *)getAdditionalTrackersWithTwoEntriesForEachEvent
{
    NSMutableDictionary *addtionalTrackersDict = [NSMutableDictionary new];

    // start trackers
    NSDictionary *startTrackerDict1 = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeStart, kTrackerTextDictionaryKey:kFirstAdditionalStartTrackerUrl};
    MPVASTTrackingEvent *startTracker1 = [[MPVASTTrackingEvent alloc] initWithDictionary:startTrackerDict1];

    NSDictionary *startTrackerDict2 = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeStart, kTrackerTextDictionaryKey:kSecondAdditionalStartTrackerUrl};
    MPVASTTrackingEvent *startTracker2 = [[MPVASTTrackingEvent alloc] initWithDictionary:startTrackerDict2];

    // firstQuartile trackers
    NSDictionary *firstQuartileTrackerDict1 = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeFirstQuartile, kTrackerTextDictionaryKey:kSecondAdditionalFirstQuartileTrackerUrl};
    MPVASTTrackingEvent *firstQuartileTracker1 = [[MPVASTTrackingEvent alloc] initWithDictionary:firstQuartileTrackerDict1];

    NSDictionary *firstQuartileTrackerDict2 = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeFirstQuartile, kTrackerTextDictionaryKey:kSecondAdditionalFirstQuartileTrackerUrl};
    MPVASTTrackingEvent *firstQuartileTracker2 = [[MPVASTTrackingEvent alloc] initWithDictionary:firstQuartileTrackerDict2];

    // midpoint trackers
    NSDictionary *midpointTrackerDict1 = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeMidpoint, kTrackerTextDictionaryKey:kFirstAdditionalMidpointTrackerUrl};
    MPVASTTrackingEvent *midpointTracker1 = [[MPVASTTrackingEvent alloc] initWithDictionary:midpointTrackerDict1];

    NSDictionary *midpointTrackerDict2 = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeMidpoint, kTrackerTextDictionaryKey:kSecondAdditionalMidpointTrackerUrl};
    MPVASTTrackingEvent *midpointTracker2 = [[MPVASTTrackingEvent alloc] initWithDictionary:midpointTrackerDict2];


    // thirdQuartile trackers
    NSDictionary *thirdQuartileTrackerDict1 = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeThirdQuartile, kTrackerTextDictionaryKey:kFirstAdditionalThirdQuartileTrackerUrl};
    MPVASTTrackingEvent *thirdQuartileTracker1 = [[MPVASTTrackingEvent alloc] initWithDictionary:thirdQuartileTrackerDict1];

    NSDictionary *thirdQuartileTrackerDict2 = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeThirdQuartile, kTrackerTextDictionaryKey:kSecondAdditionalThirdQuartileTrackerUrl};
    MPVASTTrackingEvent *thirdQuartileTracker2 = [[MPVASTTrackingEvent alloc] initWithDictionary:thirdQuartileTrackerDict2];

    // complete trackers
    NSDictionary *completeTrackerDict1 = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeComplete, kTrackerTextDictionaryKey:kFirstAdditionalCompleteTrackerUrl};
    MPVASTTrackingEvent *completeTracker1 = [[MPVASTTrackingEvent alloc] initWithDictionary:completeTrackerDict1];

    NSDictionary *completeTrackerDict2 = @{kTrackerEventDictionaryKey:MPVASTTrackingEventTypeComplete, kTrackerTextDictionaryKey:kSecondAdditionalCompleteTrackerUrl};
    MPVASTTrackingEvent *completeTracker2 = [[MPVASTTrackingEvent alloc] initWithDictionary:completeTrackerDict2];

    addtionalTrackersDict[MPVASTTrackingEventTypeStart] = @[startTracker1, startTracker2];
    addtionalTrackersDict[MPVASTTrackingEventTypeFirstQuartile] = @[firstQuartileTracker1, firstQuartileTracker2];
    addtionalTrackersDict[MPVASTTrackingEventTypeMidpoint] = @[midpointTracker1, midpointTracker2];
    addtionalTrackersDict[MPVASTTrackingEventTypeThirdQuartile] = @[thirdQuartileTracker1, thirdQuartileTracker2];
    addtionalTrackersDict[MPVASTTrackingEventTypeComplete] = @[completeTracker1, completeTracker2];

    return addtionalTrackersDict;
}


@end
