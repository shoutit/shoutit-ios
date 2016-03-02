//
//  BorderedView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class BorderedView: UIView {
    
    // boreders
    var borders: UIRectEdge = .All
    let borderColor: UIColor = UIColor(shoutitColor: .CellBackgroundGrayColor)
    let cornerRadius: CGFloat = 2.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)
        var red: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var green: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        borderColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        CGContextSetRGBStrokeColor(context, red, green, blue, alpha)
        
        if borders.contains(.Top) {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
            CGContextStrokePath(context);
        }
        if borders.contains(.Bottom) {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            CGContextStrokePath(context);
        }
        if borders.contains(.Left) {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
            CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
            CGContextStrokePath(context);
        }
        if borders.contains(.Right) {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            CGContextStrokePath(context);
        }
        
        super.drawRect(rect)
    }
}
