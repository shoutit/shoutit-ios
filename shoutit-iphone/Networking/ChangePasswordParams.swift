//
//  ChangePasswordParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct ChangePasswordParams: Params {
    public let oldPassword: String?
    public let newPassword: String
    public let newPassword2: String
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["old_password"] = oldPassword
        p["new_password"] = newPassword
        p["new_password2"] = newPassword2
        
        return p
    }
    
    public init(oldPassword: String?, newPassword: String, newPassword2: String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
        self.newPassword2 = newPassword2
    }
}
