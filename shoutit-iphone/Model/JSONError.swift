//
//  JSONError.swift
//  shoutit
//
//  Created by Piotr Bernad on 03/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum JSONError: ShoutitError {
    
    case InvalidJSON
    case UnknownError
    
    var userMessage: String {
        switch self {
        case .InvalidJSON:
            return "Provided JSON object is invalid"
            
        case .UnknownError:
            return "Unknown Error"
        }
    }
}
