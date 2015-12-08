//
//  UIView+Gradient.m
//  shoutit-iphone
//
//  Created by Alexey Ledovskiy on 5/20/15.
//  Copyright (c) 2015 Alexey Ledovskiy. All rights reserved.
//

#import "UIView+Gradient.h"


@implementation UIView (Gradient)
-(void)addGradientBlackToTransparent:(BOOL)upDown
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.name = @"gradientLayer";
    gradientLayer.frame = self.frame;
    UIColor *blackColor = [UIColor colorWithWhite:0 alpha:1.0f];
    UIColor *clearColor = [UIColor colorWithWhite:0 alpha:0.0f];
    if(upDown)
        gradientLayer.colors = [NSArray arrayWithObjects:(id)clearColor.CGColor, (id)blackColor.CGColor, nil];
    else
        gradientLayer.colors = [NSArray arrayWithObjects:(id)blackColor.CGColor,(id)clearColor.CGColor, nil];
    [self.layer insertSublayer:gradientLayer atIndex:0];
}
@end
