//
//  MPMockInterstitialCustomEvent.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPInterstitialCustomEvent.h"

@interface MPMockInterstitialCustomEvent : MPInterstitialCustomEvent
@property (nonatomic, readonly) BOOL isLocalExtrasAvailableAtRequest;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup;

@end
