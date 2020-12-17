//
//  MPMockAdDestinationDisplayAgent.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdDestinationDisplayAgent.h"

@interface MPMockAdDestinationDisplayAgent : MPAdDestinationDisplayAgent

@property (nonatomic, strong) NSURL * lastDisplayDestinationUrl;

// Override existing functionality
- (void)displayDestinationForURL:(NSURL *)URL;
@end
