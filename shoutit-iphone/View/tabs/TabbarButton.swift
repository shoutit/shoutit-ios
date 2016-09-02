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
    
    @IBInspectable var iconSize : CGSize! = CGSizeMake(26.0, 26.0)
    @IBInspectable var imageTopMargin : CGFloat = 5.0
    @IBInspectable var textHeight : CGFloat = 20
    @IBInspectable var navigationItem : String!
    
    private let badgeLabel = CustomUILabel()
    
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
        super.awakeFromNib()
        self.titleLabel?.textAlignment = .Center
        self.imageView?.contentMode = .ScaleAspectFit
        createBadgeLabel()
    }
    
    func tabNavigationItem() -> NavigationItem? {
        return NavigationItem(rawValue: self.navigationItem)
    }
    
    private func createBadgeLabel() {
        badgeLabel.backgroundColor = UIColor.redColor()
        badgeLabel.textAlignment = .Center
        badgeLabel.font = UIFont.sh_systemFontOfSize(12, weight: .Regular)
        badgeLabel.textColor = UIColor.whiteColor()
        badgeLabel.cornerRadius = 7.0
        badgeLabel.hidden = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(badgeLabel)
        
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: badgeLabel, attribute: .CenterX, multiplier: 1.0, constant: -18.0),
            NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: badgeLabel, attribute: .Top, multiplier: 1.0, constant: -2.0),
            NSLayoutConstraint(item: badgeLabel, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 14)
            ]
        )
    }
    
    func setBadgeNumber(badgeNumber: Int) {
        badgeLabel.hidden = badgeNumber < 1
        badgeLabel.text = NumberFormatters.badgeCountStringWithNumber(badgeNumber)
    }
}
