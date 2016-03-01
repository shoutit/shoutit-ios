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
        typeButton.setTitle(type.title(), forState: .Normal)
    }
    
    func setCurrency(currency: Currency?) {
        if let curr = currency {
            self.currencyButton.setTitle(curr.code, forState: .Normal)
        } else {
            self.currencyButton.setTitle(NSLocalizedString("Currency", comment: ""), forState: .Normal)
        }
    }
}
