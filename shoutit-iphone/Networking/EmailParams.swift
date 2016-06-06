//
//  EmailParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 30.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct EmailParams: Params {
    public let email: String?
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["email"] = email
        return p
    }
    
    public init(email: String?) {
        self.email = email
    }
}
