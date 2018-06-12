//
//  MPGoogleAdMobBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPBannerCustomEvent.h"
    #import "MoPub.h"
#endif

#import "MPGoogleGlobalMediationSettings.h"

/*
 * Please reference the Supported Mediation Partner page at http://bit.ly/2mqsuFH for the
 * latest version and ad format certifications.
 */
@interface MPGoogleAdMobBannerCustomEvent : MPBannerCustomEvent

@end
