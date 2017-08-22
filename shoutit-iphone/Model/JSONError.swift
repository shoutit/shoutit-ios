//
//  JSONError.swift
//  shoutit
//
//  Created by Piotr Bernad on 03/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum JSONError: ShoutitError {
    
    case invalidJSON
    case unknownError
    
    var userMessage: String {
        switch self {
        case .invalidJSON:
            return "Provided JSON object is invalid"
            
        case .unknownError:
            return "Unknown Error"
        }
    }
}
