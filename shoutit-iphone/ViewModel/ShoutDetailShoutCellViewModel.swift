//
//  ShoutDetailShoutCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

enum ShoutDetailShoutCellViewModel {
    
    case content(shout: Shout)
    case noContent(message: String)
    case loading
    case error(error: Error)
    case seeAll
    
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
        case .error, .noContent, .loading:
            return ShoutDetailShoutCellViewModel.placeholderCellReuseIdentifier
        case .content:
            return ShoutDetailShoutCellViewModel.contentCellReuseIdentifier
        case .seeAll:
            return ShoutDetailShoutCellViewModel.seeAllCellReuseIdentifier
        }
    }
    
    var title: String? {
        guard case .content(let shout) = self else {
            return nil
        }
        return shout.title
    }
    
    var authorName: String? {
        guard case .content(let shout) = self else {
            return nil
        }
        return shout.user?.name
    }
    
    var priceString: String? {
        guard case .content(let shout) = self else {
            return nil
        }
        
        if let price = shout.price, let currency = shout.currency {
            return NumberFormatters.priceStringWithPrice(price, currency: currency)
        }
        
        return nil
    }
    
    var errorMessage: String? {
        guard case .error(let error) = self else {
            return nil
        }
        return error.sh_message
    }
}
