//
//  UIButton+imageText.m
//  shoutit-iphone
//
//  Created by Alexey Ledovskiy on 3/25/15.
//  Copyright (c) 2015 Alexey Ledovskiy. All rights reserved.
//

#import "UIButton+imageText.h"

@implementation UIButton (imageText)
-(void)setLeftIcon:(UIImage*)image withSize:(CGSize)imgSize
{
    UIImageView* iconImage = (UIImageView*)[self viewWithTag:100];
    if(!iconImage)
    {
        iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(2,
                                                                      self.frame.size.height/2 - imgSize.height/2,
                                                                      imgSize.height,
                                                                      imgSize.width)];
        iconImage.tag = 100;
        [self addSubview:iconImage];
       [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 28.0, 0, 0)];

    }
    
    [iconImage setImage:image];
    [self setNeedsDisplay];
}
@end
