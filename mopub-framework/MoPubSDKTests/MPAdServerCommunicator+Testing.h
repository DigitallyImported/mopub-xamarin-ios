//
//  MPAdServerCommunicator+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdServerCommunicator.h"

#import "MPRealTimeTimer.h"

@interface MPAdServerCommunicator (Testing)

@property (nonatomic, assign, readwrite) BOOL loading;

@property (nonatomic, readonly) BOOL isRateLimited;

// Expose private methods from `MPAdServerCommunicator`
- (void)didFinishLoadingWithData:(NSData *)data;
- (void)didFailWithError:(NSError *)error;
- (NSArray *)getFlattenJsonResponses:(NSDictionary *)json keys:(NSArray *)keys;

@end
