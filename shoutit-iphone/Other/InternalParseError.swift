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
    
    var userMessage: String {
        assertionFailure()
        switch self {
        case .InvalidJson:
            return NSLocalizedString("Could not get your data", comment: "")
        }
    }
}