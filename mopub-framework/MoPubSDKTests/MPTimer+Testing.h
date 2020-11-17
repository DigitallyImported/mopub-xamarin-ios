//
//  MPTimer+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPTimer.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPTimer (Testing)
/**
 * A title string injected to Objective C runtime as associated value. Typically the test name is
 * used for timer title and unique identifier.
 */
@property (nonatomic, strong) NSString * associatedTitle;
@end

NS_ASSUME_NONNULL_END
