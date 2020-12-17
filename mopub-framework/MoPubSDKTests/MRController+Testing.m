//
//  MRController+Testing.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MRController+Testing.h"

// Suppress warning of accessing private implementation `adjustedFrameForFrame:toFitIntoApplicationSafeArea:`
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation MRController (Testing)
@dynamic mraidWebView;
@end
#pragma clang diagnostic pop
