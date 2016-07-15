//
//  ShoutCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit
import FBAudienceNetwork

struct ShoutCellViewModel {
    let shout: Shout?
    let ad: FBNativeAd?
    
    init(shout: Shout) {
        self.shout = shout
        self.ad = nil
    }
    
    init(ad: FBNativeAd) {
        self.ad = ad
        self.shout = nil
    }
    
    func priceString() -> String? {
        if let shout = shout {
            return NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
        }
        
        return nil
    }
}
