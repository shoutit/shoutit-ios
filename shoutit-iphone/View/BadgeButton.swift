//
//  BadgeButton.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 19/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class BadgeButton: UIButton {

    fileprivate let badgeLabel = CustomUILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createBadgeLabel()
    }
    
    fileprivate func createBadgeLabel() {
        badgeLabel.backgroundColor = UIColor.red
        badgeLabel.textAlignment = .center
        badgeLabel.font = UIFont.sh_systemFontOfSize(12, weight: .regular)
        badgeLabel.textColor = UIColor.white
        badgeLabel.cornerRadius = 7.0
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
