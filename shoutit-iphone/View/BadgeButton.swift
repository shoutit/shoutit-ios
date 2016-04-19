//
//  BadgeButton.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 19/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class BadgeButton: UIButton {

    private let badgeLabel = UILabel()
    
    override func awakeFromNib() {
        createBadgeLabel()
    }
    
    private func createBadgeLabel() {
        badgeLabel.backgroundColor = UIColor.redColor()
        badgeLabel.font = UIFont.sh_systemFontOfSize(12, weight: .Regular)
        badgeLabel.textColor = UIColor.whiteColor()
        badgeLabel.clipsToBounds = true
        badgeLabel.layer.cornerRadius = 7.0
        badgeLabel.hidden = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(badgeLabel)
        
        self.addConstraints([NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: badgeLabel, attribute: .CenterX, multiplier: 1.0, constant: -18.0),
            NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: badgeLabel, attribute: .Top, multiplier: 1.0, constant: -2.0)])
    }
    
    func setBadgeNumber(badgeNumber: Int) {
        badgeLabel.hidden = badgeNumber < 1
        
        if badgeNumber > 99 {
            badgeLabel.text = " \(NSLocalizedString("+99", comment: "More than 99 Notifications")) "
        } else {
            badgeLabel.text = " \(badgeNumber) "
        }
    }
}
