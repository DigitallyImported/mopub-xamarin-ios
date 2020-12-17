//
//  MPMockAdDestinationDisplayAgent.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockAdDestinationDisplayAgent.h"

@implementation MPMockAdDestinationDisplayAgent

- (void)displayDestinationForURL:(NSURL *)URL {
    self.lastDisplayDestinationUrl = URL;
}

@end
