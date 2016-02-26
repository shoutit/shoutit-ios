//
//  ShoutDetailShoutCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

struct ShoutDetailShoutCellViewModel {
    
    let shout: Shout
    
    var title: String {
        return shout.title
    }
    
    var authorName: String {
        return shout.user.name
    }
    
    var priceString: String {
        return NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
    }
}
