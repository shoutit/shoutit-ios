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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyCornerRadius()
    }
    
    private func applyCornerRadius() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
    }
}