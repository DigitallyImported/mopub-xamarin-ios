//
//  MPMockRewardedVideoCustomEvent.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPRewardedVideoCustomEvent.h"

@interface MPMockRewardedVideoCustomEvent : MPRewardedVideoCustomEvent
@property (nonatomic, readonly) BOOL isLocalExtrasAvailableAtRequest;

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup;

@end
