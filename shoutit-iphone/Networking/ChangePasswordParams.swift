//
//  ChangePasswordParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct ChangePasswordParams: Params {
    let oldPassword: String?
    let newPassword: String
    let newPassword2: String
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["old_password"] = oldPassword
        p["new_password"] = newPassword
        p["new_password2"] = newPassword2
        
        return p
    }
}
