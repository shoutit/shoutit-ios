//
//  DiscoverHeaderView.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 24.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class DiscoverHeaderView: UICollectionReusableView {
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var backgroundImageView : UIImageView!
    
    func setText(text: String, whiteWithShadow: Bool) {
        if whiteWithShadow {
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSize(width: 2, height: 2)
            shadow.shadowBlurRadius = 2
            titleLabel.attributedText = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(),
                NSShadowAttributeName : shadow
                ])
        } else {
            titleLabel.attributedText = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor(shoutitColor: .FontLighterGray)])
        }
    }
}
