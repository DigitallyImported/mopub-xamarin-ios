//
//  MPConsentDialogViewControllerTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPConsentDialogViewController.h"
#import "MPConsentDialogViewControllerDelegateHandler.h"

static NSTimeInterval const kTestTimeout = 5;

@interface MPConsentDialogViewControllerTests : XCTestCase

@end

@implementation MPConsentDialogViewControllerTests

- (void)testConsentExplicitYesResponse {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate should fire"];

    NSString *consentDialogString = @"<html><head><script type=\"text/javascript\">window.location.href = \"mopub://consent?yes\";</script></head></html>";

    MPConsentDialogViewController *vc = [[MPConsentDialogViewController alloc] initWithDialogHTML:consentDialogString];
    MPConsentDialogViewControllerDelegateHandler *delegateHandler = [[MPConsentDialogViewControllerDelegateHandler alloc] init];
    vc.delegate = delegateHandler;

    __block BOOL consentResponse = NO;
    delegateHandler.consentDialogViewControllerDidReceiveConsentResponse = ^(BOOL response, MPConsentDialogViewController *consentDialogViewController) {
        consentResponse = response;
        [expectation fulfill];
    };

    [vc loadConsentPageWithCompletion:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(consentResponse);
}

- (void)testConsentExplicitNoResponse {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate should fire"];

    NSString *consentDialogString = @"<html><head><script type=\"text/javascript\">window.location.href = \"mopub://consent?no\";</script></head></html>";

    MPConsentDialogViewController *vc = [[MPConsentDialogViewController alloc] initWithDialogHTML:consentDialogString];
    MPConsentDialogViewControllerDelegateHandler *delegateHandler = [[MPConsentDialogViewControllerDelegateHandler alloc] init];
    vc.delegate = delegateHandler;

    __block BOOL consentResponse = YES;
    delegateHandler.consentDialogViewControllerDidReceiveConsentResponse = ^(BOOL response, MPConsentDialogViewController *consentDialogViewController) {
        consentResponse = response;
        [expectation fulfill];
    };

    [vc loadConsentPageWithCompletion:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(consentResponse);
}

- (void)testMalformedQueryStringDoesNotReturn {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait on pageload"];

    NSString *consentDialogString = @"<html><head><script type=\"text/javascript\">window.location.href = \"mopub://consent?asdflkj\";</script></head></html>";

    MPConsentDialogViewController *vc = [[MPConsentDialogViewController alloc] initWithDialogHTML:consentDialogString];
    MPConsentDialogViewControllerDelegateHandler *delegateHandler = [[MPConsentDialogViewControllerDelegateHandler alloc] init];
    vc.delegate = delegateHandler;

    __block BOOL didReturn = NO;;
    delegateHandler.consentDialogViewControllerDidReceiveConsentResponse = ^(BOOL response, MPConsentDialogViewController *consentDialogViewController) {
        didReturn = YES;
    };

    [vc loadConsentPageWithCompletion:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestTimeout - 1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(didReturn);
}

- (void)testMalformedHostStringDoesNotReturn {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait on pageload"];

    NSString *consentDialogString = @"<html><head><script type=\"text/javascript\">window.location.href = \"mopub://asdfsdaf?yes\";</script></head></html>";

    MPConsentDialogViewController *vc = [[MPConsentDialogViewController alloc] initWithDialogHTML:consentDialogString];
    MPConsentDialogViewControllerDelegateHandler *delegateHandler = [[MPConsentDialogViewControllerDelegateHandler alloc] init];
    vc.delegate = delegateHandler;

    __block BOOL didReturn = NO;;
    delegateHandler.consentDialogViewControllerDidReceiveConsentResponse = ^(BOOL response, MPConsentDialogViewController *consentDialogViewController) {
        didReturn = YES;
    };

    [vc loadConsentPageWithCompletion:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestTimeout - 1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(didReturn);
}

- (void)testMalformedSchemeStringDoesNotReturn {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait on pageload"];

    NSString *consentDialogString = @"<html><head><script type=\"text/javascript\">window.location.href = \"adfasdfasf://consent?yes\";</script></head></html>";

    MPConsentDialogViewController *vc = [[MPConsentDialogViewController alloc] initWithDialogHTML:consentDialogString];
    MPConsentDialogViewControllerDelegateHandler *delegateHandler = [[MPConsentDialogViewControllerDelegateHandler alloc] init];
    vc.delegate = delegateHandler;

    __block BOOL didReturn = NO;;
    delegateHandler.consentDialogViewControllerDidReceiveConsentResponse = ^(BOOL response, MPConsentDialogViewController *consentDialogViewController) {
        didReturn = YES;
    };

    [vc loadConsentPageWithCompletion:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestTimeout - 1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(didReturn);
}

- (void)testInitialLoadCompletionBlockFires {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion block should fire"];

    NSString *consentDialogString = @"<html><body>hello</body></html>";

    MPConsentDialogViewController *vc = [[MPConsentDialogViewController alloc] initWithDialogHTML:consentDialogString];
    __block BOOL completionBlockDidFire = NO;
    [vc loadConsentPageWithCompletion:^(BOOL success, NSError *error) {
        completionBlockDidFire = YES;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(completionBlockDidFire);
}

@end
