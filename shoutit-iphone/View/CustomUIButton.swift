//
//  CustomUIButton.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 18/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

final class CustomUIButton: UIButton {

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
    
    @IBInspectable var borderColor: UIColor = UIColor.clear
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyCornerRadius()
        applyBorder()
    }
    
    fileprivate func applyCornerRadius() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
    }
    
    fileprivate func applyBorder() {
        layer.borderWidth = borderWidth / UIScreen.main.scale
        layer.borderColor = borderColor.cgColor
    }
}
