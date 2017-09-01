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
    var borders: UIRectEdge = .all
    @IBInspectable var  sh_borderColor: UIColor = UIColor(shoutitColor: .cellBackgroundGrayColor)
    @IBInspectable var sh_cornerRadius: CGFloat = 2.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2.0)
        var red: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var green: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        borderColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: alpha)
        
        let top = borders.contains(.top)
        let bottom = borders.contains(.bottom)
        let left = borders.contains(.left)
        let right = borders.contains(.right)
        
        if top {
            context?.beginPath()
            context?.move(to: CGPoint(x: rect.minX + (left ? cornerRadius : 0), y: rect.minY))
            context?.addLine(to: CGPoint(x: rect.maxX - (right ? cornerRadius : 0), y: rect.minY))
            context?.strokePath()
        }
        if bottom {
            context?.beginPath()
            context?.move(to: CGPoint(x: rect.minX + (left ? cornerRadius : 0), y: rect.maxY))
            context?.addLine(to: CGPoint(x: rect.maxX - (right ? cornerRadius : 0), y: rect.maxY))
            context?.strokePath()
        }
        if left {
            context?.beginPath()
            context?.move(to: CGPoint(x: rect.minX, y: rect.minY + (top ? cornerRadius : 0)))
            context?.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - (bottom ? cornerRadius : 0)))
            context?.strokePath()
        }
        if right {
            context?.beginPath()
            context?.move(to: CGPoint(x: rect.maxX, y: rect.minY + (top ? cornerRadius : 0)))
            context?.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (bottom ? cornerRadius : 0)))
            context?.strokePath()
        }
        if top && left {
            context?.beginPath()
            context?.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
            context?.addArc(tangent1End: CGPoint(x: rect.minX,
                                                 y: rect.minY),
                            tangent2End: CGPoint(x: rect.minX + cornerRadius,
                                                 y: rect.minY),
                            radius: cornerRadius)
            context?.strokePath()
        }
        if top && right {
            context?.beginPath()
            context?.move(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
            context?.addArc(tangent1End: CGPoint(x: rect.maxX,
                                                 y: rect.minY),
                            tangent2End: CGPoint(x: rect.maxX,
                                                 y: rect.minY + cornerRadius),
                            radius: cornerRadius)
            context?.strokePath()
        }
        if bottom && left {
            context?.beginPath()
            context?.move(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius))
            context?.addArc(tangent1End: CGPoint(x: rect.minX,
                                                 y: rect.maxY),
                            tangent2End: CGPoint(x: rect.minX + cornerRadius,
                                                 y: rect.maxY ),
                            radius: cornerRadius)
            context?.strokePath()
        }
        if bottom && right {
            context?.beginPath()
            context?.move(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
            context?.addArc(tangent1End: CGPoint(x: rect.maxX,
                                                 y: rect.maxY),
                            tangent2End: CGPoint(x: rect.maxX,
                                                 y: rect.maxY - cornerRadius ),
                            radius: cornerRadius)
      
            context?.strokePath()
        }
        
        super.draw(rect)
    }
}
