//
//  UIView+MPAdditions.m
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "UIView+MPAdditions.h"

@implementation UIView (Helper)

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (CGFloat) width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setX:(CGFloat)x
{
    [self setX:x andY:self.frame.origin.y];
}

- (void)setY:(CGFloat)y
{
    [self setX:self.frame.origin.x andY:y];
}

- (void)setX:(CGFloat)x andY:(CGFloat)y
{
    CGRect f = self.frame;
    self.frame = CGRectMake(x, y, f.size.width, f.size.height);
}


- (void)setWidth:(CGFloat)newWidth
{
    CGRect frame = self.frame;
    frame.size.width = newWidth;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)newHeight
{
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

- (UIView *)snapshotView
{
    CGRect rect = self.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.window.screen.scale);
    UIView *snapshotView;
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        snapshotView = [self snapshotViewAfterScreenUpdates:NO];
    } else {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:ctx];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        snapshotView = [[UIImageView alloc] initWithImage:image];
    }
    UIGraphicsEndImageContext();
    return snapshotView;
}

- (UIImage *)snapshot:(BOOL)usePresentationLayer
{
    CGRect rect = self.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.window.screen.scale);
    if (!usePresentationLayer && [self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    } else {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if (usePresentationLayer) {
            [self.layer.presentationLayer renderInContext:ctx];
        } else {
            [self.layer renderInContext:ctx];
        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
