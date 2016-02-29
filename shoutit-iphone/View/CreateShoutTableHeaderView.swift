//
//  CreateShoutTableHeaderView.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CreateShoutTableHeaderView: UIView {
    @IBOutlet var typeButton : UIButton!
    @IBOutlet var currencyButton : SelectButton!
    
    func fillWithType(type: ShoutType) {
        typeButton.titleLabel?.text = type.title()
    }
    
    func setCurrency(currency: Currency?) {
        if let curr = currency {
            self.currencyButton.titleLabel?.text = curr.code
        } else {
            self.currencyButton.titleLabel?.text = NSLocalizedString("Currency", comment: "")
        }
    }
}
