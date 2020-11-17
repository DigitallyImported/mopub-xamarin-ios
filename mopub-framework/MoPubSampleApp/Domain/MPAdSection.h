//
//  MPAdSection.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

@class MPAdInfo;

@interface MPAdSection : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign, readonly) NSUInteger count;

+ (NSArray *)adSections;
+ (MPAdSection *)sectionWithTitle:(NSString *)title ads:(NSArray *)ads;

- (MPAdInfo *)adAtIndex:(NSUInteger)index;

@end
