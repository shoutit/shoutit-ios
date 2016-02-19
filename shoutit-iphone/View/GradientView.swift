//
//  GradientView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Draw the gradient background
        let context = UIGraphicsGetCurrentContext();
        let colorSpace = CGColorSpaceCreateDeviceGray();
        
        // Define the shading callbacks
        var callbacks = CGFunctionCallbacks(version: 0, evaluate: {(info: UnsafeMutablePointer<Void>, inData: UnsafePointer<CGFloat>, outData: UnsafeMutablePointer<CGFloat>) -> Void in
            
            let p = inData[0]
            outData[0] = 0.0;
            let d = pow(p, 2.0);
            let slope = d/(d + pow(1.0 - p, 2.0));
            outData[1] = (1.0 - slope) * 0.5;
            }, releaseInfo: nil)
        
        // As input to our function we want 1 value in the range [0.0, 1.0].
        // This is our position within the 'gradient'.
        let domainDimension: size_t = 1
        let domain: [CGFloat] = [0.0, 1.0]
        
        // The output of our function is 2 values, each in the range [0.0, 1.0].
        // This is our selected color for the input position.
        // The 2 values are the white and alpha components.
        let rangeDimension: size_t = 2;
        let range: [CGFloat] = [0.0, 1.0, 0.0, 1.0]
        
        // Create the shading finction
        let function = CGFunctionCreate(nil, domainDimension, domain, rangeDimension, range, &callbacks)
        
        // Create the shading object
        let shading = CGShadingCreateAxial(colorSpace, CGPointMake(1, rect.size.height*0.1), CGPointMake(1, rect.size.height), function, true, true)
        
        // Draw the shading
        CGContextDrawShading(context, shading);
    }
}
