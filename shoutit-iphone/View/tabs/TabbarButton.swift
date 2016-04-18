//
//  TabbarButton.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class TabbarButton: UIButton {
    
    @IBInspectable var iconSize : CGSize! = CGSizeMake(26.0, 26.0)
    @IBInspectable var imageTopMargin : CGFloat = 5.0
    @IBInspectable var textHeight : CGFloat = 20
    @IBInspectable var navigationItem : String!

    @IBInspectable var selectedTintColor : UIColor! = UIColor.darkGrayColor() {
        didSet {
            setTitleColor(selectedTintColor, forState: .Selected)
            
            if (selected || highlighted) {
                self.tintColor = selectedTintColor
            }
        }
    }
    
    @IBInspectable var normalTintColor : UIColor! = UIColor.darkGrayColor() {
        didSet {
            setTitleColor(normalTintColor, forState: .Normal)
            
            if (!selected && !highlighted) {
                self.tintColor = normalTintColor
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            self.tintColor = selected ? selectedTintColor : normalTintColor
        }
    }
    
    override func awakeFromNib() {
        self.titleLabel?.textAlignment = .Center
        self.imageView?.contentMode = .ScaleAspectFit
    }
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        return CGRectMake(CGRectGetMidX(contentRect) - iconSize.width * 0.5, imageTopMargin, iconSize.width, iconSize.height)
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        return CGRectMake(0, CGRectGetMaxY(contentRect) - textHeight, CGRectGetWidth(contentRect), textHeight)
    }
    
    func tabNavigationItem() -> NavigationItem? {
        return NavigationItem(rawValue: self.navigationItem)
    }
}
