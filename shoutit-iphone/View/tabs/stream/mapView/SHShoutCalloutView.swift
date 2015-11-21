//
//  SHShoutCalloutView.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 18/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHShoutCalloutView: UIView {
    
    
    
    func setShout(shout: SHShout, withAccessoryBloack: (SHShout) -> ()) {
//        self.shout = shout
//        if(shout.thumbnail != "") {
//            self.im
//        }
    }
//    -(void)setShout:(SHShout*)shout withAccessoryBlock:(void (^)(SHShout* shout))accessoryAction
//    {
//    self.shout = shout;
//    self.accessoryBlock = accessoryAction;
//    if (![shout.thumbnail  isEqual: @""])
//    {
//    
//    [self.imageViewShout setImageWithURL:[NSURL URLWithString:[shout.thumbnail smallImage]] placeholderImage:[UIImage imageNamed:@"image_placeholder"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] ;
//    }
//    else{
//    [self.imageViewShout setImage:[UIImage imageNamed:@"no_image_available"]];
//    }
//    [self.imageViewShout setContentMode:UIViewContentModeScaleAspectFill];
//    [self.imageViewShout setClipsToBounds:YES];
//    //    [self.imageViewShout.layer setBorderColor:[UIColor colorWithHex:@"#e8e8e8"].CGColor];
//    //    [self.imageViewShout.layer setBorderWidth:2.0];
//    [self.imageViewShout.layer setCornerRadius:self.imageViewShout.frame.size.width/15.0];
//    
//    UIImage *imgMask = [UIImage imageNamed:@"shoutMask.png"];
//    CALayer *mask = [CALayer layer];
//    mask.contents = (id)[imgMask CGImage];
//    mask.frame = CGRectMake(0, 0, self.imageViewShout.frame.size.width, self.imageViewShout.frame.size.height);
//    self.imageViewShout.layer.mask = mask;
//    self.imageViewShout.layer.masksToBounds = YES;
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[shout.date_published integerValue]]; // [dateFormatter dateFromString: shout.date_published];
//    [self.timeLabel setText:[date timeAgoSimple]];
//    
//    NSString *price = [NSString stringWithFormat:@"%@ %@", [shout findCurrencySymbolByCode:shout.currency], shout.price];
//    [self.priceLabel setText:price];
//    
//    [self.descriptionLabel setText:shout.text];
//    [self.titleLabel setText:shout.title];
//    
//    }

}
