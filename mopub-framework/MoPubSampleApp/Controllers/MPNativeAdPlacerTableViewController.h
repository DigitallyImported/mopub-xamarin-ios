//
//  MPNativeAdPlacerTableViewController.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
@class MPAdInfo;

@interface MPNativeAdPlacerTableViewController : UITableViewController

- (id)initWithAdInfo:(MPAdInfo *)info;

@end

