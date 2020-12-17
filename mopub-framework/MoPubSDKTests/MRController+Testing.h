//
//  MRController+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPClosableView.h"
#import "MRController.h"
#import "MPWebView.h"

@interface MRController (Testing)
@property (nonatomic, strong) MPWebView *mraidWebView;

+ (BOOL)isValidResizeFrame:(CGRect)frame
     inApplicationSafeArea:(CGRect)applicationSafeArea
            allowOffscreen:(BOOL)allowOffscreen;

+ (BOOL)isValidCloseButtonPlacement:(MPClosableViewCloseButtonLocation)closeButtonLocation
                          inAdFrame:(CGRect)adFrame
              inApplicationSafeArea:(CGRect)applicationSafeArea;

+ (CGRect)adjustedFrameForFrame:(CGRect)frame toFitIntoApplicationSafeArea:(CGRect)applicationSafeArea;

@end
