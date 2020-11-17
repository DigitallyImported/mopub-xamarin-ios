//
//  MPStubCustomEvent.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoCustomEvent.h"

@interface MPStubCustomEvent : MPRewardedVideoCustomEvent
+ (BOOL) isInitialized;
+ (void)resetInitialization;
@end
