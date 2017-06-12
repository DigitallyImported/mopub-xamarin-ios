//
//  VungleRewardedVideoCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPRewardedVideoCustomEvent.h"
#endif

/*
 * Please reference the Supported Mediation Partner page at http://bit.ly/2mqsuFH for the
 * latest version and ad format certifications.
 *
 * The Vungle SDK does not provide an "application will leave" callback, thus this custom event
 * will not invoke the rewardedVideoWillLeaveApplicationForCustomEvent: delegate method.
 */
@interface VungleRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

@end
