//
//  HomeSectionHeader.swift
//  shoutit
//
//  Created by Piotr Bernad on 30/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class HomeSectionHeader: UIStackView {

    @IBOutlet var rightButton : UIButton!
    @IBOutlet var leftLabel : UILabel!
    
    class func instanceFromNib() -> HomeSectionHeader {
        return UINib(nibName: "HomeSectionHeader", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! HomeSectionHeader
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.rightButton.layer.borderWidth = 1.0
        self.rightButton.layer.borderColor = (self.rightButton.titleColorForState(.Normal) ?? UIColor.blackColor()).CGColor
        self.rightButton.layer.cornerRadius = 2.0
        self.rightButton.titleEdgeInsets = UIEdgeInsetsMake(10, -20.0, 10, -20.0)
    }
}
