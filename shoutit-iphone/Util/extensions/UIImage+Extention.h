//
//  UIImage+Extention.h
//  shoutit-iphone
//
//  Created by Alexey Ledovskiy on 11/26/14.
//  Copyright (c) 2014 Alexey Ledovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extention)
- (UIImage*) maskImage:(UIImage *) image withMask:(UIImage *) mask;
-(UIImage *)resizeImageProportionallyIntoNewSize:(CGSize)newSize;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
-(UIImage *) scaleAndRotateImage:(UIImage *)image;
- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size;
@end
