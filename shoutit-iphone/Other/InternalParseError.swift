//
//  InternalParseError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum InternalParseError: ShoutitError {
    case InvalidJson
    case Currency
    case User
    
    var userMessage: String {
        assert(false)
        switch self {
        case .InvalidJson:
            return NSLocalizedString("Could not get your data", comment: "")
        case .Currency:
            return NSLocalizedString("Could not load currencies", comment: "")
        case .User:
            return NSLocalizedString("Could not get user.", comment: "")
        }
    }
}