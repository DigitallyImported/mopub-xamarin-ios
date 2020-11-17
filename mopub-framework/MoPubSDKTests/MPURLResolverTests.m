//
//  MPURLResolverTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPURLResolver.h"
#import "MoPub.h"

static NSString * const kWebviewClickthroughURLBase = @"https://ads.mopub.com/m/aclk?appid=&cid=dfc18f7f101e40489e2a091c845a1cab&city=Burlingame&ckv=2&country_code=US&cppck=4C7BD&dev=x86_64&exclude_adgroups=0769f1d048214c4f9ff4c05d9871a95b&id=abc6bfe824634bc1b70dfc2cc78c6940&is_mraid=0&os=iOS&osv=10.3.0&req=083033d5e9b9412f9b37ae08468191c7&reqt=1495340380.0&rev=0&udid=ifa%3A237E6BB9-EF1B-4287-B21E-42A39A69D3BB&video_type=";

@interface MPURLResolver (Testing)

@property (nonatomic, readonly) BOOL shouldOpenWithInAppWebBrowser;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
- (NSDictionary *)appStoreProductParametersForURL:(NSURL *)URL;
#pragma clang diagnostic pop

@end

@interface MPURLResolverTests : XCTestCase

@end

@implementation MPURLResolverTests

- (void)testResolverNonHttpNorHttps {
    NSURL *url = [NSURL URLWithString:@"mopubnativebrowser://navigate?url=https://twitter.com"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];


    XCTAssertFalse(resolver.shouldOpenWithInAppWebBrowser);
}

- (void)testResolverSupportedAppleSchemes {
    NSArray * supportedAppleStoreSubdomains = @[@"apps", @"books", @"itunes", @"music"];

    for (NSString *subdomain in supportedAppleStoreSubdomains) {
        NSString *testUrlString = [NSString stringWithFormat:@"https://%@.apple.com/id123456789", subdomain];
        NSURL *testUrl = [NSURL URLWithString:testUrlString];
        XCTAssertNotNil(testUrl);

        MPURLResolver *resolver = [MPURLResolver resolverWithURL:testUrl completion:nil];
        [resolver start];
        XCTAssertFalse(resolver.shouldOpenWithInAppWebBrowser);
    }
}

- (void)testResolverRedirectedSupportedAppleSchemes {
    NSArray * supportedAppleStoreSubdomains = @[@"apps", @"books", @"itunes", @"music"];

    for (NSString *subdomain in supportedAppleStoreSubdomains) {
        NSString *testUrlString = [NSString stringWithFormat:@"%@&r=https%%3A%%2F%%2F%@.apple.com%%2Fid123456789", kWebviewClickthroughURLBase, subdomain];
        NSURL *testUrl = [NSURL URLWithString:testUrlString];
        XCTAssertNotNil(testUrl);

        MPURLResolver *resolver = [MPURLResolver resolverWithURL:testUrl completion:nil];
        [resolver start];
        XCTAssertFalse(resolver.shouldOpenWithInAppWebBrowser);
    }
}

- (void)testResolverAppleDeeplinkSchemes {
    NSArray * appleStoreDeeplinkSchemes = @[@"itms", @"itmss", @"itms-apps"];

    for (NSString *scheme in appleStoreDeeplinkSchemes) {
        NSString *testUrlString = [NSString stringWithFormat:@"%@://itunes.apple.com/app/apple-store/id123456789", scheme];
        NSURL *testUrl = [NSURL URLWithString:testUrlString];
        XCTAssertNotNil(testUrl);

        MPURLResolver *resolver = [MPURLResolver resolverWithURL:testUrl completion:nil];
        [resolver start];
        XCTAssertFalse(resolver.shouldOpenWithInAppWebBrowser);
    }
}

- (void)testHttpRedirectWithNativeSafari {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", kWebviewClickthroughURLBase, @"&r=https%3A%2F%2Fwww.mopub.com%2F"];
    NSURL *url = [NSURL URLWithString:urlStr];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertFalse(resolver.shouldOpenWithInAppWebBrowser);
}

- (void)testHttpRedirectWithInAppBrowser {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeInApp];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", kWebviewClickthroughURLBase, @"&r=https%3A%2F%2Fwww.mopub.com%2F"];
    NSURL *url = [NSURL URLWithString:urlStr];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertTrue(resolver.shouldOpenWithInAppWebBrowser);
}

- (void)testMopubnativebrowserRedirectWithNativeSafari {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];

    NSString *urlStr = [NSString stringWithFormat:@"%@%@", kWebviewClickthroughURLBase, @"&r=mopubnativebrowser://navigate?url=https://twitter.com"];
    NSURL *url = [NSURL URLWithString:urlStr];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertFalse(resolver.shouldOpenWithInAppWebBrowser);
}

- (void)testHttpNonRedirectWithNativeSafari {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];
    NSURL *url = [NSURL URLWithString:kWebviewClickthroughURLBase];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertFalse(resolver.shouldOpenWithInAppWebBrowser);
}

- (void)testNonWebviewWithNativeSafari {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];

    NSURL *url = [NSURL URLWithString:@"https://ads.mopub.com"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertFalse(resolver.shouldOpenWithInAppWebBrowser);
}

- (void)testNonWebviewWithInappBrowser {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeInApp];

    NSURL *url = [NSURL URLWithString:@"https://ads.mopub.com"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertTrue(resolver.shouldOpenWithInAppWebBrowser);
}

- (void)testValidAppleStoreURLParsing {
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/album/fame-monster-deluxe-version/id902143901?mt=1&at=123456&app=itunes&ct=newsletter1"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    NSDictionary *parameters = [resolver appStoreProductParametersForURL:url];

    XCTAssertNotNil(parameters);
    XCTAssert([parameters[SKStoreProductParameterITunesItemIdentifier] isEqualToString:@"902143901"]);
    XCTAssert([parameters[SKStoreProductParameterAffiliateToken] isEqualToString:@"123456"]);
    XCTAssert([parameters[SKStoreProductParameterCampaignToken] isEqualToString:@"newsletter1"]);
}

- (void)testValidAppleStoreURLParsingOnlyId {
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/album/fame-monster-deluxe-version/902143901"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    NSDictionary *parameters = [resolver appStoreProductParametersForURL:url];

    XCTAssertNotNil(parameters);
    XCTAssert([parameters[SKStoreProductParameterITunesItemIdentifier] isEqualToString:@"902143901"]);
}

- (void)testInvalidAppleStoreURLParsingMissingId {
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/album/fame-monster-deluxe-version/?mt=1&at=123456&app=itunes&ct=newsletter1"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    NSDictionary *parameters = [resolver appStoreProductParametersForURL:url];

    XCTAssertNil(parameters);
}

- (void)testInvalidAppleStoreURLParsingBadId {
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/album/fame-monster-deluxe-version/id902143901zzz?mt=1&at=123456&app=itunes&ct=newsletter1"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    NSDictionary *parameters = [resolver appStoreProductParametersForURL:url];

    XCTAssertNil(parameters);
}

- (void)testInvalidAppleStoreURLParsingNotAppleUrl {
    NSURL *url = [NSURL URLWithString:@"https://www.google.com"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    NSDictionary *parameters = [resolver appStoreProductParametersForURL:url];

    XCTAssertNil(parameters);
}

@end
