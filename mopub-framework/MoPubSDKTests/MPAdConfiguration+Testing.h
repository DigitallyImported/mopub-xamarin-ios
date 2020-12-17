//
//  MPAdConfiguration+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdConfiguration.h"

@interface MPAdConfiguration (Testing)

@property (nonatomic) NSInteger clickthroughExperimentBrowserAgent;

- (NSArray <NSURL *> *)URLsFromMetadata:(NSDictionary *)metadata forKey:(NSString *)key;
- (NSArray <NSString *> *)URLStringsFromMetadata:(NSDictionary *)metadata forKey:(NSString *)key;

@end
