//
//  CustomUIImageView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class CustomUIImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
        applyCornerRadius()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyCornerRadius()
    }
    
    fileprivate func applyCornerRadius() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
    }
}
