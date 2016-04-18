//
//  CustomUITextField.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 19/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

final class CustomUITextField: TextFieldValidator {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var leftRightMargin: CGFloat = 0 {
        didSet {
            self.layoutSubviews()
        }
    }
    
    @IBInspectable var placeHolderTextColor: UIColor? {
        didSet {
            if let color = placeHolderTextColor, placeHolderString = placeholder {
                attributedPlaceholder = NSAttributedString(string: placeHolderString, attributes: [NSForegroundColorAttributeName:color])
            }
        }
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, leftRightMargin, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, leftRightMargin, 0)
    }
    
}
