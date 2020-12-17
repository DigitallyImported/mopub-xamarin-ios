//
//  MPAdServerCommunicatorDelegateHandler.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdServerCommunicator.h"

@interface MPAdServerCommunicatorDelegateHandler : NSObject <MPAdServerCommunicatorDelegate>

@property (nonatomic, copy) void (^communicatorDidReceiveAdConfigurations)(NSArray<MPAdConfiguration *> *configurations);
@property (nonatomic, copy) void (^communicatorDidFailWithError)(NSError *error);
@property (nonatomic, copy) MPAdType (^adTypeForAdServerCommunicator)(MPAdServerCommunicator *adServerCommunicator);
@property (nonatomic, copy) NSString * (^adUnitIdForAdServerCommunicator)(MPAdServerCommunicator *adServerCommunicator);

@end
