//
//  MPNativeCollectionViewAdCollectionViewCell.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPNativeAdRendering.h"


@interface MPNativeCollectionViewAdCollectionViewCell : UICollectionViewCell <MPNativeAdRendering>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIImageView *DAAIconImageView;
@property (strong, nonatomic) UILabel *ctaLabel;

@end
