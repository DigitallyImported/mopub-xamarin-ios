//
//  MPAdServerURLBuilder+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdServerURLBuilder.h"

@interface MPAdServerURLBuilder (Testing)

+ (NSString *)advancedBiddingValue;
+ (NSDictionary<NSString *, NSString *> *)adapterInformation;

@end
