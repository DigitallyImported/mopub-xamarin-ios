//
//  MPVASTLinearAdTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTManager.h"
#import "MPVASTResponse.h"
#import "MPVideoConfig.h"
#import "XCTestCase+MPAddition.h"

static const NSTimeInterval kDefaultTimeout = 1;

@interface MPVASTLinearAdTests : XCTestCase

@end

@implementation MPVASTLinearAdTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Test that the highest bitrate supported media file is selected.
- (void)testHighestBitrateSelection {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for fetching data from xml."];

    __block NSData *vastData = [self dataFromXMLFileNamed:@"linear-mime-types" class:[self class]];
    __block MPVASTResponse *vastResponse;
    [MPVASTManager fetchVASTWithData:vastData completion:^(MPVASTResponse *response, NSError *error) {
        XCTAssertNil(error);
        vastResponse = response;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    // linear-mime-types.xml has 10 media files, with the highest valid bitrate of 1458 and URL of
    // https://gcdn.2mdn.net/videoplayback/id/883bff9aabab6c02/itag/344/source/doubleclick_dmm/ratebypass/yes/acao/yes/ip/0.0.0.0/ipbits/0/expire/3622019356/sparams/id,itag,source,ratebypass,acao,ip,ipbits,expire/signature/9464D3C90825A4EA90C4E1C2D4DC82A164CB2F5C.8BC8A2FC95DF6E4724B0FF5D23A7B8DA6AE11493/key/ck2/file/file.mp4
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];

    XCTAssertTrue([videoConfig.mediaURL.absoluteString isEqualToString:@"https://gcdn.2mdn.net/videoplayback/id/883bff9aabab6c02/itag/344/source/doubleclick_dmm/ratebypass/yes/acao/yes/ip/0.0.0.0/ipbits/0/expire/3622019356/sparams/id,itag,source,ratebypass,acao,ip,ipbits,expire/signature/9464D3C90825A4EA90C4E1C2D4DC82A164CB2F5C.8BC8A2FC95DF6E4724B0FF5D23A7B8DA6AE11493/key/ck2/file/file.mp4"]);
}

- (void)testAllMediaFilesInvalid {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for fetching data from xml."];

    __block NSData *vastData = [self dataFromXMLFileNamed:@"linear-mime-types-all-invalid" class:[self class]];
    __block MPVASTResponse *vastResponse;
    [MPVASTManager fetchVASTWithData:vastData completion:^(MPVASTResponse *response, NSError *error) {
        XCTAssertNil(error);
        vastResponse = response;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    // linear-mime-types-all-invalid.xml has 2 media files, all invalid
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];

    XCTAssertNil(videoConfig.mediaURL);
}


@end
