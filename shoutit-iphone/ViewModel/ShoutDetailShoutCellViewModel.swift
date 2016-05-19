//
//  ShoutDetailShoutCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ShoutDetailShoutCellViewModel {
    
    case Content(shout: Shout)
    case NoContent(message: String)
    case Loading
    case Error(error: ErrorType)
    case SeeAll
    
    static var placeholderCellReuseIdentifier: String {
        return "PlaceholderCellReuseIdentifier"
    }
    
    static var contentCellReuseIdentifier: String {
        return "ContentCellReuseIdentifier"
    }
    
    static var seeAllCellReuseIdentifier: String {
        return "SeeAllCellReuseIdentifier"
    }
    
    var cellReuseIdentifier: String {
        switch self {
        case .Error, .NoContent, .Loading:
            return ShoutDetailShoutCellViewModel.placeholderCellReuseIdentifier
        case .Content:
            return ShoutDetailShoutCellViewModel.contentCellReuseIdentifier
        case .SeeAll:
            return ShoutDetailShoutCellViewModel.seeAllCellReuseIdentifier
        }
    }
    
    var title: String? {
        guard case .Content(let shout) = self else {
            return nil
        }
        return shout.title
    }
    
    var authorName: String? {
        guard case .Content(let shout) = self else {
            return nil
        }
        return shout.user?.name
    }
    
    var priceString: String? {
        guard case .Content(let shout) = self else {
            return nil
        }
        
        if let price = shout.price, currency = shout.currency {
            return NumberFormatters.priceStringWithPrice(price, currency: currency)
        }
        
        return nil
    }
    
    var errorMessage: String? {
        guard case .Error(let error) = self else {
            return nil
        }
        return error.sh_message
    }
}
