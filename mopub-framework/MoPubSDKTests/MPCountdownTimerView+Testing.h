//
//  MPCountdownTimerView+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPCountdownTimerView.h"
#import "MPTimer.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPCountdownTimerView (Testing)

@property (nonatomic, readonly) MPTimer * timer;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter; // do not use `defaultCenter` for unit tests

@end

NS_ASSUME_NONNULL_END
