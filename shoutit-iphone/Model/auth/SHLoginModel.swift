//
//  SHLoginModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 04/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHLoginModel: Model { //, GIDSignInDelegate, GIDSignInUIDelegate
    
    //var selfUser: SHUser
    var googleAuth: GIDAuthentication!
    var loginMethod = Int()
    var access_token = String()
    var token_type = String()
    var expires_in = String()
    var tokenCreatedAt = String()
    var refresh_token = String()
    var scope = String()
    var isActive = Bool()
    
}
