//
//  GreenSegmentedControl.swift
//  shoutit
//
//  Created by Piotr Bernad on 08/09/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class GreenSegmentedControl: UISegmentedControl {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(shoutitColor: .PrimaryGreen)
        
        removeBorders()
        
    }

}

extension GreenSegmentedControl {
    func removeBorders() {
        
        setBackgroundImage(imageWithColor(UIColor(shoutitColor: .PrimaryGreen)), forState: .Normal, barMetrics: .Default)
        setBackgroundImage(imageWithColor(UIColor(shoutitColor: .PrimaryGreen)), forState: .Selected, barMetrics: .Default)
        setDividerImage(imageWithColor(UIColor.clearColor()), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
}