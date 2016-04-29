//
//  RTLShoutItemCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class RTLShoutItemCell: SHShoutItemCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
            transform = CGAffineTransformMakeScale(-1, 1)
        }
    }
}
