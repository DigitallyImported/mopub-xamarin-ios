//
//  MPAdTableViewController.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdInfo.h"

@interface MPAdTableViewController : UITableViewController

- (id)initWithAdSections:(NSArray *)sections;
- (void)loadAd:(MPAdInfo *)info;

@end
