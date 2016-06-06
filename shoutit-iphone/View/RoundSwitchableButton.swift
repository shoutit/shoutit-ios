//
//  RoundSwitchableButton.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 06.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class RoundSwitchableButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        layer.cornerRadius = bounds.width * 0.5
    }
    
    func setOn() {
        setOn(true)
    }
    
    func setOff() {
        setOn(false)
    }
    
    func setOn(on: Bool) {
        backgroundColor = on ? UIColor(shoutitColor: .ShoutitLightBlueColor) : UIColor.blackColor().colorWithAlphaComponent(0.38)
        layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.7).CGColor
        layer.borderWidth = on ? 0 : 2
    }
}

