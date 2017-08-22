//
//  BubbleView.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class BubbleView: UIView {

    @IBInspectable var fillColor : UIColor! = UIColor.gray
    @IBInspectable var strokeColor : UIColor! = UIColor.lightGray
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentMode = .redraw
    }
    
    override func draw(_ rect: CGRect) {

        let rectangle : UIBezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10))
        
        fillColor.setFill()
        strokeColor.setStroke()

        rectangle.lineWidth = 1.0 / UIScreen.main.nativeScale
        
        rectangle.fill()
        rectangle.stroke()
    }
}
