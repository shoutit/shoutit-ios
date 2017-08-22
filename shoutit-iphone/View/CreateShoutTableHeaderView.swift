//
//  CreateShoutTableHeaderView.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

final class CreateShoutTableHeaderView: UIView {
    @IBOutlet var currencyButton : SelectionButton!
    @IBOutlet var titleTextField : UITextField!
    @IBOutlet var priceTextField : UITextField!
    
    func setCurrency(_ currency: ShoutitKit.Currency?) {
        if let curr = currency {
            self.currencyButton.setTitle(curr.code, for: UIControlState())
        } else {
            self.currencyButton.setTitle(NSLocalizedString("Currency", comment: "Create Shout Currency Button Title"), for: UIControlState())
        }
    }
}
