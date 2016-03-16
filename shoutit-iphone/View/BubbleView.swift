//
//  BubbleView.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class BubbleView: UIView {

    @IBInspectable var fillColor : UIColor! = UIColor.grayColor()
    @IBInspectable var strokeColor : UIColor! = UIColor.lightGrayColor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentMode = .Redraw
    }
    
    override func drawRect(rect: CGRect) {

        let rectangle : UIBezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: 10, height: 10))
        
        fillColor.setFill()
        strokeColor.setStroke()

        rectangle.lineWidth = 1.0 / UIScreen.mainScreen().nativeScale
        
        rectangle.fill()
        rectangle.stroke()
    }
}
