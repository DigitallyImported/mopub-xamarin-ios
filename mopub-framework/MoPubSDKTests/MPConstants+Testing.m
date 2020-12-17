//
//  MPConstants+Testing.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPConstants+Testing.h"

static NSTimeInterval const kAdsExpirationTimeIntervalForTesting = 1; // 1 second

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@implementation MPConstants (Testing)

+ (NSTimeInterval)adsExpirationInterval {
    return kAdsExpirationTimeIntervalForTesting;
}

@end
#pragma clang diagnostic pop
