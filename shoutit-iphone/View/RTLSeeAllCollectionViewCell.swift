//
//  RTLSeeAllCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class RTLSeeAllCollectionViewCell: SeeAllCollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
}
