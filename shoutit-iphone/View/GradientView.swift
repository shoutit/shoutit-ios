//
//  GradientView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class GradientView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
//        // Draw the gradient background
//        let context = UIGraphicsGetCurrentContext();
//        let colorSpace = CGColorSpaceCreateDeviceGray();
//        
//        
//        // Define the shading callbacks
//        var callbacks = CGFunctionCallbacks(version: 0, evaluate: {(info: UnsafeMutableRawPointer, inData: UnsafePointer<CGFloat>, outData: UnsafeMutablePointer<CGFloat>) -> Void in
//            
//            let p = inData[0]
//            outData[0] = 0.0;
//            let d = pow(p, 2.0);
//            let slope = d/(d + pow(1.0 - p, 2.0));
//            outData[1] = (1.0 - slope) * 0.5;
//            } as! CGFunctionEvaluateCallback, releaseInfo: nil)
//        
//        // As input to our function we want 1 value in the range [0.0, 1.0].
//        // This is our position within the 'gradient'.
//        let domainDimension: size_t = 1
//        let domain: [CGFloat] = [0.0, 1.0]
//        
//        // The output of our function is 2 values, each in the range [0.0, 1.0].
//        // This is our selected color for the input position.
//        // The 2 values are the white and alpha components.
//        let rangeDimension: size_t = 2;
//        let range: [CGFloat] = [0.0, 1.0, 0.0, 1.0]
//        
//        // Create the shading finction
//        let function = CGFunction(info: nil, domainDimension: domainDimension, domain: domain, rangeDimension: rangeDimension, range: range, callbacks: &callbacks)
//        
//        // Create the shading object
//        let shading = CGShading(axialSpace: colorSpace, start: CGPoint(x: 1, y: rect.size.height*0.1), end: CGPoint(x: 1, y: rect.size.height), function: function!, extendStart: true, extendEnd: true)
//        
//        // Draw the shading
//        context?.drawShading(shading!);
    }
}
