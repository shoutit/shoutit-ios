//
//  ShoutItErrors.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 19.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension ErrorType {
    var sh_message: String {
        if let e = self as? ShoutitError {
            return e.message
        }
        return (self as NSError).localizedDescription
    }
}

protocol ShoutitError: ErrorType {
    var message: String {get}
}

struct LightError: ShoutitError {
    let message: String
}

enum ParseError: ShoutitError {
    case InvalidJson
    case AuthData
    case Categories
    case Currency
    case Suggestions
    case User
    case Success
    case Shouts
    
    var message: String {
        assert(false)
        switch self {
        case .InvalidJson:
            return NSLocalizedString("Could not get your data", comment: "")
        case .AuthData:
            return NSLocalizedString("Could not authorize", comment: "")
        case .Categories:
            return NSLocalizedString("Could not load categories", comment: "")
        case .Suggestions:
            return NSLocalizedString("Could not load suggestions", comment: "")
        case .Currency:
            return NSLocalizedString("Could not load currencies", comment: "")
        case .User:
            return NSLocalizedString("Could not get user.", comment: "")
        case .Shouts:
            return NSLocalizedString("Could not get shouts.", comment: "")
        case .Success:
            return ""
        }
    }
}
