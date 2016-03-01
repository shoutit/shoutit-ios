//
//  CustomUILabel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CustomUILabel: UILabel {
    
    private let textPadding: CGFloat = 2
    
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
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: textPadding, bottom: 0, right: textPadding)
        let insetsRect = UIEdgeInsetsInsetRect(rect, insets)
        super.drawTextInRect(insetsRect)
    }
    
    override func intrinsicContentSize() -> CGSize {
        let defaultSize = super.intrinsicContentSize()
        return CGSize(width: defaultSize.width + 2 * textPadding, height: defaultSize.height)
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
