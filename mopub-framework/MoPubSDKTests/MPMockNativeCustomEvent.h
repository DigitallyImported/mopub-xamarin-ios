//
//  MPMockNativeCustomEvent.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPNativeCustomEvent.h"
#import "MPNativeAdRendering.h"

@interface MPMockNativeCustomEvent : MPNativeCustomEvent
@property (nonatomic, readonly) BOOL isLocalExtrasAvailableAtRequest;
@property (nonatomic, assign) NSTimeInterval simulatedLoadTimeInterval;

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup;

@end

@interface MPMockNativeCustomEventView : UIView<MPNativeAdRendering>
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *mainTextLabel;
@property (strong, nonatomic) UILabel *callToActionLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIImageView *privacyInformationIconImageView;
@end
