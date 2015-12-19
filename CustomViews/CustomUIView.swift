//
//  CustomUIView.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 18/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

@IBDesignable
class CustomUIView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
            layer.masksToBounds = borderWidth > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }

}
