//
//  ShadowView.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 24.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ShadowView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0 / UIScreen.main.scale
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.shadowOpacity = 0.7

    }
}
