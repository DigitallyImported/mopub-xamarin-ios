//
//  MPAdConfigurationFactory.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdConfiguration.h"

@interface MPAdConfigurationFactory : NSObject

+ (MPAdConfiguration *)clearResponse;

+ (NSMutableDictionary *)defaultNativeProperties;
+ (MPAdConfiguration *)defaultNativeAdConfiguration;
+ (MPAdConfiguration *)defaultNativeAdConfigurationWithCustomEventClassName:(NSString *)eventClassName;
+ (MPAdConfiguration *)defaultNativeAdConfigurationWithCustomEventClassName:(NSString *)eventClassName
                                                         additionalMetadata:(NSDictionary *)additionalMetadata;
+ (MPAdConfiguration *)defaultNativeAdConfigurationWithNetworkType:(NSString *)type;
+ (MPAdConfiguration *)defaultNativeAdConfigurationWithHeaders:(NSDictionary *)dictionary
                                                    properties:(NSDictionary *)properties;

+ (NSMutableDictionary *)defaultBannerHeaders;
+ (MPAdConfiguration *)defaultBannerConfiguration;
+ (MPAdConfiguration *)defaultBannerConfigurationWithNetworkType:(NSString *)type;
+ (MPAdConfiguration *)defaultBannerConfigurationWithCustomEventClassName:(NSString *)eventClassName;
+ (MPAdConfiguration *)defaultBannerConfigurationWithCustomEventClassName:(NSString *)eventClassName
                                                       additionalMetadata:(NSDictionary *)additionalMetadata;
+ (MPAdConfiguration *)defaultBannerConfigurationWithHeaders:(NSDictionary *)dictionary
                                                  HTMLString:(NSString *)HTMLString;

+ (NSMutableDictionary *)defaultInterstitialHeaders;
+ (MPAdConfiguration *)defaultInterstitialConfiguration;
+ (MPAdConfiguration *)defaultMRAIDInterstitialConfiguration;
+ (MPAdConfiguration *)defaultFakeInterstitialConfiguration;
+ (MPAdConfiguration *)defaultInterstitialConfigurationWithNetworkType:(NSString *)type;
+ (MPAdConfiguration *)defaultChartboostInterstitialConfigurationWithLocation:(NSString *)location;
+ (MPAdConfiguration *)defaultInterstitialConfigurationWithCustomEventClassName:(NSString *)eventClassName;
+ (MPAdConfiguration *)defaultInterstitialConfigurationWithCustomEventClassName:(NSString *)eventClassName
                                                             additionalMetadata:(NSDictionary *)additionalMetadata;
+ (MPAdConfiguration *)defaultInterstitialConfigurationWithHeaders:(NSDictionary *)dictionary
                                                        HTMLString:(NSString *)HTMLString;

+ (NSMutableDictionary *)defaultRewardedVideoHeaders;
+ (MPAdConfiguration *)defaultRewardedVideoConfiguration;
+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithCustomEventClassName:(NSString *)eventClassName;
+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithCustomEventClassName:(NSString *)eventClassName
                                                              additionalMetadata:(NSDictionary *)additionalMetadata;
+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithReward;
+ (MPAdConfiguration *)defaultRewardedVideoConfigurationServerToServer;
+ (MPAdConfiguration *)defaultNativeVideoConfigurationWithVideoTrackers;

@end
