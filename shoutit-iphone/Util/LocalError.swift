//
//  LocalError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum LocalError: ShoutitError {
    
    case cancelled
    case unknownError
    
    var userMessage: String {
        switch self {
        case .cancelled:
            return "Cancelled"
        case .unknownError:
            return ""
        }
    }
}
