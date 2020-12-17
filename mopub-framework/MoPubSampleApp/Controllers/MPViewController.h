//
//  MPViewController.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>

@interface MPViewController : UIViewController
@property (nonatomic, readonly) NSTimeInterval lastTimeInterval;

- (void)startTimer;
- (void)endTimer;
@end
