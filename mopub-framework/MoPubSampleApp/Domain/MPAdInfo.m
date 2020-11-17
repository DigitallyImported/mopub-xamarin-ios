//
//  MPAdInfo.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdInfo.h"

#import <Foundation/Foundation.h>

NSString * const kAdInfoIdKey = @"adUnitId";
NSString * const kAdInfoFormatKey = @"format";
NSString * const kAdInfoKeywordsKey = @"keywords";
NSString * const kAdInfoNameKey = @"name";

@implementation MPAdInfo

+ (NSDictionary *)supportedAddedAdTypes
{
    static NSDictionary *adTypes = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        adTypes = @{@"Banner":@(MPAdInfoBanner), @"Interstitial":@(MPAdInfoInterstitial), @"MRect":@(MPAdInfoMRectBanner), @"Leaderboard":@(MPAdInfoLeaderboardBanner), @"Native":@(MPAdInfoNative), @"Rewarded Video":@(MPAdInfoRewardedVideo), @"Rewarded":@(MPAdInfoRewardedVideo), @"NativeTablePlacer":@(MPAdInfoNativeTableViewPlacer), @"NativeCollectionPlacer":@(MPAdInfoNativeInCollectionView)};
    });

    return adTypes;
}

+ (NSArray *)bannerAds
{
    NSMutableArray *ads = [NSMutableArray array];

    [ads addObjectsFromArray:@[
                               [MPAdInfo infoWithTitle:@"HTML Banner Ad" ID:@"0ac59b0996d947309c33f59d6676399f" type:MPAdInfoBanner],
                               [MPAdInfo infoWithTitle:@"MRAID Banner Ad" ID:@"23b49916add211e281c11231392559e4" type:MPAdInfoBanner],
                               [MPAdInfo infoWithTitle:@"HTML MRECT Banner Ad" ID:@"2aae44d2ab91424d9850870af33e5af7" type:MPAdInfoMRectBanner],
                               ]];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [ads addObject:[MPAdInfo infoWithTitle:@"HTML Leaderboard Banner Ad" ID:@"d456ea115eec497ab33e02531a5efcbc" type:MPAdInfoLeaderboardBanner]];
    }

    return ads;
}

+ (NSArray *)interstitialAds
{
    return @[
             [MPAdInfo infoWithTitle:@"HTML Interstitial Ad" ID:@"4f117153f5c24fa6a3a92b818a5eb630" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"MRAID Interstitial Ad" ID:@"3aba0056add211e281c11231392559e4" type:MPAdInfoInterstitial],
             ];
}

+ (NSArray *)rewardedVideoAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Rewarded Video Ad" ID:@"8f000bd5e00246de9c789eed39ff6096" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"Rewarded Rich Media Ad" ID:@"98c29e015e7346bd9c380b1467b33850" type:MPAdInfoRewardedVideo],
             ];
}

+ (NSArray *)nativeAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Native Ad" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Native Video Ad" ID:@"b2b67c2a8c0944eda272ed8e4ddf7ed4" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Native Ad (CollectionView Placer)" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNativeInCollectionView],
             [MPAdInfo infoWithTitle:@"Native Ad (TableView Placer)" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNativeTableViewPlacer],
             [MPAdInfo infoWithTitle:@"Native Video Ad (TableView Placer)" ID:@"b2b67c2a8c0944eda272ed8e4ddf7ed4" type:MPAdInfoNativeTableViewPlacer],
             ];
}

+ (MPAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID type:(MPAdInfoType)type {
    MPAdInfo *info = [[MPAdInfo alloc] init];
    info.title = title;
    info.ID = ID;
    info.type = type;
    return info;
}

+ (MPAdInfo *)infoWithDictionary:(NSDictionary *)dict
{
    // Extract the required fields from the dictionary. If either of the required fields
    // is invalid, object creation will not be performed.
    NSString * adUnitId = [[dict objectForKey:kAdInfoIdKey] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * formatString = [[dict objectForKey:kAdInfoFormatKey] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * keywords = [[dict objectForKey:kAdInfoKeywordsKey] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * name = [[dict objectForKey:kAdInfoNameKey] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if (adUnitId.length == 0 || formatString.length == 0 || (formatString != nil && [[self supportedAddedAdTypes] objectForKey:formatString] == nil)) {
        return nil;
    }

    MPAdInfoType format = (MPAdInfoType)[[[self supportedAddedAdTypes] objectForKey:formatString] integerValue];
    NSString * title = (name != nil ? name : adUnitId);
    MPAdInfo * info = [MPAdInfo infoWithTitle:title ID:adUnitId type:format];
    info.keywords = keywords;

    return info;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.keywords = [aDecoder decodeObjectForKey:@"keywords"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:((self.keywords != nil) ? self.keywords : @"") forKey:@"keywords"];
}

@end
