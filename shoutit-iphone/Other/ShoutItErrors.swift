//
//  ShoutItErrors.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 19.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public protocol ShoutitError: ErrorType {
    var userMessage: String {get}
}

extension ErrorType {
    public var sh_message: String {
        if let e = self as? ShoutitError {
            return e.userMessage
        }
        
        return ((self as Any) as! NSError).localizedDescription
    }
}
