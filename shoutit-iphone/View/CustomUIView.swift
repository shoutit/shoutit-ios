//
//  CustomUIView.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 18/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

final class CustomUIView: UIView {

    @IBInspectable var sh_cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = sh_cornerRadius
            updateMaskToBounds()
        }
    }
    
    @IBInspectable var sh_borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = sh_borderWidth
            updateMaskToBounds()
        }
    }
    
    @IBInspectable var sh_borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = sh_borderColor.cgColor
        }
    }
    
    func updateMaskToBounds() {
        layer.masksToBounds = sh_cornerRadius > 0 || sh_borderWidth > 0
    }

}
