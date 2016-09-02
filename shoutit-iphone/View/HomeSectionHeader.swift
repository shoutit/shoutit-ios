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
    
}
