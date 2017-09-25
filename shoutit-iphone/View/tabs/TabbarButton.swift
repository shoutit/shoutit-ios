//
//  TabbarButton.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

final class TabbarButton: UIButton {
    
    @IBInspectable var iconSize : CGSize! = CGSize(width: 26.0, height: 26.0)
    @IBInspectable var imageTopMargin : CGFloat = 5.0
    @IBInspectable var textHeight : CGFloat = 20
    @IBInspectable var navigationItem : String!
    
    fileprivate let badgeLabel = CustomUILabel()
    
    @IBInspectable var selectedTintColor : UIColor! = UIColor.darkGray {
        didSet {
            setTitleColor(selectedTintColor, for: .selected)
            
            if (isSelected || isHighlighted) {
                self.tintColor = selectedTintColor
            }
        }
    }
    
    @IBInspectable var normalTintColor : UIColor! = UIColor.darkGray {
        didSet {
            setTitleColor(normalTintColor, for: UIControlState())
            
            if (!isSelected && !isHighlighted) {
                self.tintColor = normalTintColor
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.tintColor = isSelected ? selectedTintColor : normalTintColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.textAlignment = .center
        self.imageView?.contentMode = .scaleAspectFit
        createBadgeLabel()
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: contentRect.midX - iconSize.width * 0.5, y: imageTopMargin, width: iconSize.width, height: iconSize.height)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: 0, y: contentRect.maxY - textHeight, width: contentRect.width, height: textHeight)
    }
    
    func tabNavigationItem() -> NavigationItem? {
        return NavigationItem(rawValue: self.navigationItem)
    }
    
    fileprivate func createBadgeLabel() {
        badgeLabel.backgroundColor = UIColor.red
        badgeLabel.textAlignment = .center
        badgeLabel.font = UIFont.sh_systemFontOfSize(12, weight: .regular)
        badgeLabel.textColor = UIColor.white
        badgeLabel.sh_cornerRadius = 7.0
        badgeLabel.isHidden = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(badgeLabel)
        
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: badgeLabel, attribute: .centerX, multiplier: 1.0, constant: -18.0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: badgeLabel, attribute: .top, multiplier: 1.0, constant: -2.0),
            NSLayoutConstraint(item: badgeLabel, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 14)
            ]
        )
    }
    
    func setBadgeNumber(_ badgeNumber: Int) {
        badgeLabel.isHidden = badgeNumber < 1
        badgeLabel.text = NumberFormatters.badgeCountStringWithNumber(badgeNumber)
    }
}
