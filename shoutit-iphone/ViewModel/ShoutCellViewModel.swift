//
//  ShoutCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct ShoutCellViewModel {
    let shout: Shout
    
    init(shout: Shout) {
        self.shout = shout
    }
    
    func priceString() -> String? {
        return NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
    }
}
