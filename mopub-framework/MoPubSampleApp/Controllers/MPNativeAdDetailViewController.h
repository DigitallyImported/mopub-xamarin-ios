//
//  MPNativeAdDetailViewController.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPViewController.h"

@class MPAdInfo;

extern NSString *const kNativeAdDefaultActionViewKey;

@interface MPNativeAdDetailViewController : MPViewController

- (id)initWithAdInfo:(MPAdInfo *)info;

@end
