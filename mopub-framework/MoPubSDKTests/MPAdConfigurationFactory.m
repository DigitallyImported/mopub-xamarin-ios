//
//  MPAdConfigurationFactory.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdConfigurationFactory.h"
#import "MPNativeAd.h"

#define kImpressionTrackerURLsKey   @"imptracker"
#define kClickTrackerURLKey         @"clktracker"
#define kDefaultActionURLKey        @"clk"

extern NSString *const kNativeVideoTrackersMetadataKey;

@implementation MPAdConfigurationFactory

+ (MPAdConfiguration *)clearResponse
{
    NSDictionary * metadata = @{ kAdTypeMetadataKey: kAdTypeClear };
    return [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];
}

#pragma mark - Native

+ (NSMutableDictionary *)defaultNativeAdHeaders
{
    return [@{
              kAdTypeMetadataKey: kAdTypeNative,
              kNextUrlMetadataKey: @"http://ads.mopub.com/m/failURL",
              kRefreshTimeMetadataKey: @"61",
              } mutableCopy];
}

+ (NSMutableDictionary *)defaultNativeProperties
{
    return [@{@"ctatext":@"Download",
              @"iconimage":@"image_url",
              @"mainimage":@"image_url",
              @"text":@"This is an ad",
              @"title":@"Sample Ad Title",
              kClickTrackerURLKey:@"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kImpressionTrackerURLsKey:@[@"http://ads.mopub.com/m/impressionTracker"],
              kDefaultActionURLKey:@"http://mopub.com"
              } mutableCopy];
}

+ (MPAdConfiguration *)defaultNativeAdConfiguration
{
    return [self defaultNativeAdConfigurationWithHeaders:nil properties:nil];
}

+ (MPAdConfiguration *)defaultNativeAdConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultNativeAdConfigurationWithHeaders:@{kAdTypeMetadataKey: type}
                                              properties:nil];
}

+ (MPAdConfiguration *)defaultNativeAdConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [self defaultNativeAdConfigurationWithCustomEventClassName:eventClassName additionalMetadata:nil];
}

+ (MPAdConfiguration *)defaultNativeAdConfigurationWithCustomEventClassName:(NSString *)eventClassName
                                                         additionalMetadata:(NSDictionary *)additionalMetadata
{
    NSMutableDictionary * metadata = [NSMutableDictionary dictionaryWithDictionary:@{ kCustomEventClassNameMetadataKey: eventClassName, kAdTypeMetadataKey: @"custom"}];
    if (additionalMetadata.count > 0) {
        [metadata addEntriesFromDictionary:additionalMetadata];
    }

    return [MPAdConfigurationFactory defaultNativeAdConfigurationWithHeaders:metadata
                                                                  properties:nil];
}


+ (MPAdConfiguration *)defaultNativeAdConfigurationWithHeaders:(NSDictionary *)dictionary
                                                    properties:(NSDictionary *)properties
{
    NSMutableDictionary *headers = [self defaultBannerHeaders];
    [headers addEntriesFromDictionary:dictionary];

    NSMutableDictionary *allProperties = [self defaultNativeProperties];
    if (properties) {
        [allProperties addEntriesFromDictionary:properties];
    }

    return [[MPAdConfiguration alloc] initWithMetadata:headers data:[NSJSONSerialization dataWithJSONObject:allProperties options:NSJSONWritingPrettyPrinted error:nil] adType:MPAdTypeInline];
}

#pragma mark - Banners

+ (NSMutableDictionary *)defaultBannerHeaders
{
    return [@{
              kAdTypeMetadataKey: kAdTypeHtml,
              kClickthroughMetadataKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kNextUrlMetadataKey: @"http://ads.mopub.com/m/failURL",
              kHeightMetadataKey: @"50",
              kImpressionTrackerMetadataKey: @"http://ads.mopub.com/m/impressionTracker",
              kRefreshTimeMetadataKey: @"30",
              kWidthMetadataKey: @"320"
              } mutableCopy];
}

+ (MPAdConfiguration *)defaultBannerConfiguration
{
    return [self defaultBannerConfigurationWithHeaders:nil HTMLString:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultBannerConfigurationWithHeaders:@{kAdTypeMetadataKey: type}
                                            HTMLString:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [self defaultBannerConfigurationWithCustomEventClassName:eventClassName additionalMetadata:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithCustomEventClassName:(NSString *)eventClassName additionalMetadata:(NSDictionary *)additionalMetadata
{
    NSMutableDictionary * metadata = [NSMutableDictionary dictionaryWithDictionary:@{ kCustomEventClassNameMetadataKey: eventClassName, kAdTypeMetadataKey: @"custom"}];
    if (additionalMetadata.count > 0) {
        [metadata addEntriesFromDictionary:additionalMetadata];
    }

    return [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:metadata HTMLString:nil];
}


+ (MPAdConfiguration *)defaultBannerConfigurationWithHeaders:(NSDictionary *)dictionary
                                                  HTMLString:(NSString *)HTMLString
{
    NSMutableDictionary *headers = [self defaultBannerHeaders];
    [headers addEntriesFromDictionary:dictionary];

    HTMLString = HTMLString ? HTMLString : @"Publisher's Ad";

    return [[MPAdConfiguration alloc] initWithMetadata:headers
                                                 data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding] adType:MPAdTypeInline];
}

#pragma mark - Interstitials

+ (NSMutableDictionary *)defaultInterstitialHeaders
{
    return [@{
              kAdTypeMetadataKey: kAdTypeInterstitial,
              kClickthroughMetadataKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kNextUrlMetadataKey: @"http://ads.mopub.com/m/failURL",
              kImpressionTrackerMetadataKey: @"http://ads.mopub.com/m/impressionTracker",
              kInterstitialAdTypeMetadataKey: kAdTypeHtml,
              kOrientationTypeMetadataKey: @"p"
              } mutableCopy];
}

+ (MPAdConfiguration *)defaultInterstitialConfiguration
{
    return [self defaultInterstitialConfigurationWithHeaders:nil HTMLString:nil];
}

+ (MPAdConfiguration *)defaultMRAIDInterstitialConfiguration
{
    NSDictionary *headers = @{
                              kAdTypeMetadataKey: @"mraid",
                              kOrientationTypeMetadataKey: @"p"
                              };

    return [self defaultInterstitialConfigurationWithHeaders:headers
                                                  HTMLString:nil];
}

+ (MPAdConfiguration *)defaultChartboostInterstitialConfigurationWithLocation:(NSString *)location
{
    MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"ChartboostInterstitialCustomEvent"];
    NSMutableDictionary *data = [@{@"appId": @"myAppId",
                                   @"appSignature": @"myAppSignature"} mutableCopy];

    if (location) {
        data[@"location"] = location;
    }

    configuration.customEventClassData = data;
    return configuration;
}

+ (MPAdConfiguration *)defaultFakeInterstitialConfiguration
{
    return [self defaultInterstitialConfigurationWithNetworkType:@"fake"];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultInterstitialConfigurationWithHeaders:@{kInterstitialAdTypeMetadataKey: type}
                                                  HTMLString:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [self defaultInterstitialConfigurationWithCustomEventClassName:eventClassName additionalMetadata:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithCustomEventClassName:(NSString *)eventClassName additionalMetadata:(NSDictionary *)additionalMetadata
{
    NSMutableDictionary * metadata = [NSMutableDictionary dictionaryWithDictionary:@{ kCustomEventClassNameMetadataKey: eventClassName, kAdTypeMetadataKey: @"custom"}];
    if (additionalMetadata.count > 0) {
        [metadata addEntriesFromDictionary:additionalMetadata];
    }

    return [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:metadata
                                                                      HTMLString:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithHeaders:(NSDictionary *)dictionary
                                                        HTMLString:(NSString *)HTMLString
{
    NSMutableDictionary *headers = [self defaultInterstitialHeaders];
    [headers addEntriesFromDictionary:dictionary];

    HTMLString = HTMLString ? HTMLString : @"Publisher's Interstitial";

    return [[MPAdConfiguration alloc] initWithMetadata:headers
                                                 data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding] adType:MPAdTypeInline];
}

#pragma mark - Rewarded Video
+ (NSMutableDictionary *)defaultRewardedVideoHeaders
{
    return [@{
              kAdTypeMetadataKey: @"custom",
              kClickthroughMetadataKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kNextUrlMetadataKey: @"http://ads.mopub.com/m/failURL",
              kImpressionTrackerMetadataKey: @"http://ads.mopub.com/m/impressionTracker",
              kInterstitialAdTypeMetadataKey: kAdTypeHtml,
              } mutableCopy];
}

+ (NSMutableDictionary *)defaultRewardedVideoHeadersWithReward
{
    NSMutableDictionary *dict = [[self defaultRewardedVideoHeaders] mutableCopy];
    dict[kRewardedVideoCurrencyNameMetadataKey] = @"gold";
    dict[kRewardedVideoCurrencyAmountMetadataKey] = @"12";
    return dict;
}

+ (NSMutableDictionary *)defaultRewardedVideoHeadersServerToServer
{
    NSMutableDictionary *dict = [[self defaultRewardedVideoHeaders] mutableCopy];
    dict[kRewardedVideoCompletionUrlMetadataKey] = @"http://ads.mopub.com/m/rewarded_video_completion?req=332dbe5798d644309d9d950321d37e3c&reqt=1460590468.0&id=54c94899972a4d4fb00c9cbf0fd08141&cid=303d4529ee3b42e7ac1f5c19caf73515&udid=ifa%3A3E67D059-6F94-4C88-AD2A-72539FE13795&cppck=09CCC";
    return dict;
}

+ (NSMutableDictionary *)defaultNativeVideoHeadersWithTrackers
{
    NSMutableDictionary *dict = [[self defaultNativeAdHeaders] mutableCopy];
    dict[kNativeVideoTrackersMetadataKey] = @"{\"urls\": [\"http://mopub.com/%%VIDEO_EVENT%%/foo\", \"http://mopub.com/%%VIDEO_EVENT%%/bar\"],\"events\": [\"start\", \"firstQuartile\", \"midpoint\", \"thirdQuartile\", \"complete\"]}";
    return dict;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfiguration
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:[self defaultRewardedVideoHeaders] data:nil adType:MPAdTypeFullscreen];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [self defaultInterstitialConfigurationWithCustomEventClassName:eventClassName additionalMetadata:nil];
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithCustomEventClassName:(NSString *)eventClassName additionalMetadata:(NSDictionary *)additionalMetadata
{
    NSMutableDictionary * metadata = [NSMutableDictionary dictionaryWithDictionary:[self defaultRewardedVideoHeaders]];
    metadata[kCustomEventClassNameMetadataKey] = eventClassName;
    if (additionalMetadata.count > 0) {
        [metadata addEntriesFromDictionary:additionalMetadata];
    }

    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil adType:MPAdTypeFullscreen];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithReward
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:[self defaultRewardedVideoHeadersWithReward] data:nil adType:MPAdTypeFullscreen];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationServerToServer
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:[self defaultRewardedVideoHeadersServerToServer] data:nil adType:MPAdTypeFullscreen];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultNativeVideoConfigurationWithVideoTrackers
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:[self defaultNativeVideoHeadersWithTrackers] data:nil adType:MPAdTypeFullscreen];
    return adConfiguration;
}

@end
