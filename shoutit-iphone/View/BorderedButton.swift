//
//  BorderedButton.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 24.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class BorderedButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0 / UIScreen.main.scale
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
    }
}
