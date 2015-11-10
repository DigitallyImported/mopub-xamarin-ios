//
//  UIView+MPAdditions.h
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MPAdditions)

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;

- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;

- (UIView *)snapshotView;

// convert any UIView to UIImage view. We can apply blur effect on UIImage.
- (UIImage *)snapshot:(BOOL)usePresentationLayer;

@end
