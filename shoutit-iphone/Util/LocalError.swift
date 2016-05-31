//
//  LocalError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum LocalError: ShoutitError {
    
    case Cancelled
    case UnknownError
    
    var userMessage: String {
        switch self {
        case .Cancelled:
            return "Cancelled"
        case .UnknownError:
            return ""
        }
    }
}