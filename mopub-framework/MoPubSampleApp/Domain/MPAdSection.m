//
//  MPAdSection.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdSection.h"
#import "MPAdInfo.h"
#import "MPAdPersistenceManager.h"

@interface MPAdSection ()

@property (nonatomic, strong) NSArray *ads;

@end

@implementation MPAdSection

+ (NSArray *)adSections
{
    return @[
             [MPAdSection sectionWithTitle:@"Banner Ads" ads:[MPAdInfo bannerAds]],
             [MPAdSection sectionWithTitle:@"Interstitial Ads" ads:[MPAdInfo interstitialAds]],
             [MPAdSection sectionWithTitle:@"Rewarded Video Ads" ads:[MPAdInfo rewardedVideoAds]],
             [MPAdSection sectionWithTitle:@"Native Ads" ads:[MPAdInfo nativeAds]],
             [MPAdSection sectionWithTitle:@"Saved Ads" ads:[MPAdPersistenceManager sharedManager].savedAds]
             ];
}

+ (MPAdSection *)sectionWithTitle:(NSString *)title ads:(NSArray *)ads
{
    MPAdSection *section = [[MPAdSection alloc] init];
    section.title = title;
    section.ads = ads;
    return section;
}

- (MPAdInfo *)adAtIndex:(NSUInteger)index
{
    return [self.ads objectAtIndex:index];
}

- (NSUInteger)count
{
    return [self.ads count];
}

@end
