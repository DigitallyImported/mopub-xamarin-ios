//
//  MPInterstitialAdManager+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInterstitialAdManager.h"

@interface MPInterstitialAdManager (Testing)
@property (nonatomic, strong) MPAdServerCommunicator * communicator;
@property (nonatomic, strong) MPBaseInterstitialAdapter * adapter;
@end
