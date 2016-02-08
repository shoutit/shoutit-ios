//
//  AuthData.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct AuthData {
    
    // token type
    private(set) var guest: Bool = false
    
    // token
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    
    // user
    let user: User
    
    // other
    let isNewSignUp: Bool
    let scope: String
}

extension AuthData: MappableObject {
    
    init(map: Map) throws {
        accessToken = try map.extract("access_token")
        expiresIn = try map.extract("expires_in")
        isNewSignUp = try map.extract("new_signup")
        refreshToken = try map.extract("refresh_token")
        scope = try map.extract("scope")
        tokenType = try map.extract("token_type")
        user = try map.extract("user")
    }
    
    func sequence(map: Map) throws {
        try accessToken         ~> map["access_token"]
        try expiresIn           ~> map["expires_in"]
        try isNewSignUp         ~> map["new_signup"]
        try refreshToken        ~> map["refresh_token"]
        try scope               ~> map["scope"]
        try tokenType           ~> map["token_type"]
        try user                ~> map["user"]
    }
}
