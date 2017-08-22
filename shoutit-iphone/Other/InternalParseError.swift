//
//  InternalParseError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum InternalParseError: ShoutitError {
    case invalidJson
    
    var userMessage: String {
        assertionFailure()
        switch self {
        case .invalidJson:
            return NSLocalizedString("Could not get your data", comment: "Invalid JSON Error Message")
        }
    }
}
