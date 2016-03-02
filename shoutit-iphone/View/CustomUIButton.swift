//
//  CustomUIButton.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 18/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class CustomUIButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            applyCornerRadius()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            applyBorder()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyCornerRadius()
        applyBorder()
    }
    
    private func applyCornerRadius() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
    }
    
    private func applyBorder() {
        layer.borderWidth = borderWidth / UIScreen.mainScreen().scale
        layer.borderColor = borderColor.CGColor
    }
}
