//
//  MPMockLongLoadNativeCustomEvent.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockLongLoadNativeCustomEvent.h"

@implementation MPMockLongLoadNativeCustomEvent

- (instancetype)init {
    if (self = [super init]) {
        self.simulatedLoadTimeInterval = 8.0;
    }

    return self;
}

@end
