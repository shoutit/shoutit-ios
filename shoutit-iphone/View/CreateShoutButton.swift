//
//  CreateShoutButton.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 11/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class CreateShoutButton: UIButton {
    
    override func awakeFromNib() {
        
        if (UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft) {
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30.0, bottom: 0, right: 0.0)
        } else {
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10.0)
        }
    }
}
