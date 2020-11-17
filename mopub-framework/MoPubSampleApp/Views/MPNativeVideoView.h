//
//  MPNativeVideoView.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPNativeAdRendering.h"


@interface MPNativeVideoView : UIView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *mainTextLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIView *videoView;
@property (strong, nonatomic) UIImageView *privacyInformationIconImageView;
@property (strong, nonatomic) UILabel *ctaLabel;

@end
