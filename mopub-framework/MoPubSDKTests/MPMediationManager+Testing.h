//
//  MPMediationManager+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMediationManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPMediationManager (Testing)
@property (class, nonatomic, copy, nullable) NSString * adapterInformationProvidersFilePath;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<MPAdapterConfiguration>> * adapters;
@property (nonatomic, strong, readonly) NSSet<Class<MPAdapterConfiguration>> * certifiedAdapterClasses;

+ (NSSet<Class<MPAdapterConfiguration>> * _Nonnull)certifiedAdapterInformationProviderClasses;
- (NSDictionary<NSString *, NSString *> *)parametersForAdapter:(id<MPAdapterConfiguration>)adapter
                                         overrideConfiguration:(NSDictionary<NSString *, NSString *> *)configuration;
@end

NS_ASSUME_NONNULL_END
