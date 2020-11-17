//
//  MPAdInfo.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

// Valid dictionary keys used for `MPAdInfo` initialization.
extern NSString * const kAdInfoIdKey;       // Non-nil, non-empty `NSString`
extern NSString * const kAdInfoFormatKey;   // Non-nil, non-empty `NSString`
extern NSString * const kAdInfoKeywordsKey; // Optional comma-delimited `NSString`
extern NSString * const kAdInfoNameKey;     // Optional name for the ad unit as a `NSString`

typedef NS_ENUM(NSInteger, MPAdInfoType) {
    MPAdInfoBanner,
    MPAdInfoInterstitial,
    MPAdInfoMRectBanner,
    MPAdInfoLeaderboardBanner,
    MPAdInfoNative,
    MPAdInfoNativeTableViewPlacer,
    MPAdInfoNativePageViewControllerPlacer,
    MPAdInfoNativeInCollectionView,
    MPAdInfoRewardedVideo
};

@interface MPAdInfo : NSObject <NSCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, assign) MPAdInfoType type;
@property (nonatomic, copy) NSString *keywords;

+ (NSArray *)bannerAds;
+ (NSArray *)interstitialAds;
+ (NSArray *)rewardedVideoAds;
+ (NSArray *)nativeAds;
+ (MPAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID type:(MPAdInfoType)type;
+ (MPAdInfo *)infoWithDictionary:(NSDictionary *)dict;
+ (NSDictionary *)supportedAddedAdTypes;

@end
