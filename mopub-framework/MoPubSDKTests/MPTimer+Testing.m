//
//  MPTimer+Testing.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <objc/runtime.h>
#import "MPTimer+Testing.h"

@implementation MPTimer (Testing)

@dynamic associatedTitle;

- (void)setAssociatedTitle:(NSString *)title {
    objc_setAssociatedObject(self, @selector(associatedTitle), title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)associatedTitle {
    return objc_getAssociatedObject(self, @selector(associatedTitle));
}

@end
