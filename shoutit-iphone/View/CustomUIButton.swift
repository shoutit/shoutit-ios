//
//  CustomUIButton.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 18/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

final class CustomUIButton: UIButton {

    @IBInspectable var sh_cornerRadius: CGFloat = 0 {
        didSet {
            applyCornerRadius()
        }
    }
    
    @IBInspectable var sh_borderWidth: CGFloat = 0 {
        didSet {
            applyBorder()
        }
    }
    
    @IBInspectable var sh_borderColor: UIColor = UIColor.clear
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyCornerRadius()
        applyBorder()
    }
    
    fileprivate func applyCornerRadius() {
        layer.cornerRadius = sh_cornerRadius
        layer.masksToBounds = sh_cornerRadius > 0
    }
    
    fileprivate func applyBorder() {
        layer.borderWidth = sh_borderWidth / UIScreen.main.scale
        layer.borderColor = sh_borderColor.cgColor
    }
}
