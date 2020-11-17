//
//  MPAdPersistenceManager.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

@class MPAdInfo;

@interface MPAdPersistenceManager : NSObject
{
    NSMutableArray *_savedAds;
}

@property (nonatomic, readonly) NSArray *savedAds;

+ (MPAdPersistenceManager *)sharedManager;

- (void)addSavedAd:(MPAdInfo *)adInfo;
- (void)removeSavedAd:(MPAdInfo *)adInfo;
- (MPAdInfo *)savedAdForID:(NSString *)adID;

@end
