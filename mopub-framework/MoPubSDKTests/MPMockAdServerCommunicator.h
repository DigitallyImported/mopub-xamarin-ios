//
//  MPMockAdServerCommunicator.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdServerCommunicator.h"

@interface MPMockAdServerCommunicator : MPAdServerCommunicator
@property (nonatomic, strong) NSArray<MPAdConfiguration *> * mockConfigurationsResponse;
@property (nonatomic, strong) NSURL * lastUrlLoaded;
@property (nonatomic, assign) BOOL loadMockResponsesOnce;
@property (nonatomic, assign) NSUInteger numberOfBeforeLoadEventsFired;
@property (nonatomic, assign) NSUInteger numberOfAfterLoadEventsFired;
@property (nonatomic, assign) BOOL lastAfterLoadResultWasTimeout;

- (void)loadURL:(NSURL *)URL;

@end
