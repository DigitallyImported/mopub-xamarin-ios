//
//  MPNativeAdDelegateHandler.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPNativeAdDelegate.h"

typedef void(^MPNativeAdDelegateHandlerBlock)(MPNativeAd *);
typedef UIViewController *(^MPNativeAdDelegateHandlerPresentingViewControllerBlock)(void);
typedef void(^MPNativeAdDelegateHandlerImpressionDataBlock)(MPNativeAd *, MPImpressionData *);

@interface MPNativeAdDelegateHandler : NSObject <MPNativeAdDelegate>

@property (nonatomic, copy) MPNativeAdDelegateHandlerBlock willPresentModal;
@property (nonatomic, copy) MPNativeAdDelegateHandlerBlock didPresentModal;
@property (nonatomic, copy) MPNativeAdDelegateHandlerBlock willLeaveApplication;
@property (nonatomic, copy) MPNativeAdDelegateHandlerPresentingViewControllerBlock viewControllerForModal;
@property (nonatomic, copy) MPNativeAdDelegateHandlerImpressionDataBlock didTrackImpression;

@end
