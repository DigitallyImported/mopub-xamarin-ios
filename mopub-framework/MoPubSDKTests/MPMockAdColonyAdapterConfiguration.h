//
//  MPMockAdColonyAdapterConfiguration.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPBaseAdapterConfiguration.h"

@interface MPMockAdColonyAdapterConfiguration : MPBaseAdapterConfiguration
@property (class, nonatomic, assign) BOOL isSdkInitialized;

@property (nonatomic, copy, readonly) NSString * _Nonnull adapterVersion;
@property (nonatomic, copy, readonly) NSString * _Nullable biddingToken;
@property (nonatomic, copy, readonly) NSString * _Nonnull moPubNetworkName;
@property (nonatomic, copy, readonly) NSString * _Nonnull networkSdkVersion;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, NSString *> * _Nullable)configuration
                                  complete:(void(^ _Nullable)(NSError * _Nullable))complete;
@end
