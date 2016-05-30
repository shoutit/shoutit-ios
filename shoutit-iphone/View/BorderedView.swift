//
//  BorderedView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class BorderedView: UIView {
    
    // boreders
    var borders: UIRectEdge = .All
    @IBInspectable var  borderColor: UIColor = UIColor(shoutitColor: .CellBackgroundGrayColor)
    @IBInspectable var cornerRadius: CGFloat = 2.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 2.0)
        var red: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var green: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        borderColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        CGContextSetRGBStrokeColor(context, red, green, blue, alpha)
        
        let top = borders.contains(.Top)
        let bottom = borders.contains(.Bottom)
        let left = borders.contains(.Left)
        let right = borders.contains(.Right)
        
        if top {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, CGRectGetMinX(rect) + (left ? cornerRadius : 0), CGRectGetMinY(rect))
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect) - (right ? cornerRadius : 0), CGRectGetMinY(rect))
            CGContextStrokePath(context)
        }
        if bottom {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, CGRectGetMinX(rect) + (left ? cornerRadius : 0), CGRectGetMaxY(rect))
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect) - (right ? cornerRadius : 0), CGRectGetMaxY(rect))
            CGContextStrokePath(context)
        }
        if left {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect) + (top ? cornerRadius : 0))
            CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) - (bottom ? cornerRadius : 0))
            CGContextStrokePath(context)
        }
        if right {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect) + (top ? cornerRadius : 0))
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - (bottom ? cornerRadius : 0))
            CGContextStrokePath(context)
        }
        if top && left {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect) + cornerRadius)
            CGContextAddArcToPoint(context,
                                   CGRectGetMinX(rect),
                                   CGRectGetMinY(rect),
                                   CGRectGetMinX(rect) + cornerRadius,
                                   CGRectGetMinY(rect),
                                   cornerRadius)
            CGContextStrokePath(context)
        }
        if top && right {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, CGRectGetMaxX(rect) - cornerRadius, CGRectGetMinY(rect))
            CGContextAddArcToPoint(context,
                                   CGRectGetMaxX(rect),
                                   CGRectGetMinY(rect),
                                   CGRectGetMaxX(rect),
                                   CGRectGetMinY(rect) + cornerRadius,
                                   cornerRadius)
            CGContextStrokePath(context)
        }
        if bottom && left {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) - cornerRadius)
            CGContextAddArcToPoint(context,
                                   CGRectGetMinX(rect),
                                   CGRectGetMaxY(rect),
                                   CGRectGetMinX(rect) + cornerRadius,
                                   CGRectGetMaxY(rect),
                                   cornerRadius)
            CGContextStrokePath(context)
        }
        if bottom && right {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, CGRectGetMaxX(rect) - cornerRadius, CGRectGetMaxY(rect))
            CGContextAddArcToPoint(context,
                                   CGRectGetMaxX(rect),
                                   CGRectGetMaxY(rect),
                                   CGRectGetMaxX(rect),
                                   CGRectGetMaxY(rect) - cornerRadius,
                                   cornerRadius)
            CGContextStrokePath(context)
        }
        
        super.drawRect(rect)
    }
}
