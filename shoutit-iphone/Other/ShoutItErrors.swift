//
//  ShoutItErrors.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 19.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ShoutitError: ErrorType {
    var message: String {get}
}

enum ParseError: ShoutitError {
    case InvalidJson
    case AuthData
    case Categories
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
        case .User:
            return NSLocalizedString("Could not get user.", comment: "")
        case .Shouts:
            return NSLocalizedString("Could not get shouts.", comment: "")
        case .Success:
            return ""
        }
    }
}
