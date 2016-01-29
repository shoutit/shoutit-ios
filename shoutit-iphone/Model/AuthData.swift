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
    
    // token
    private(set) var accessToken: String = ""
    private(set) var refreshToken: String = ""
    private(set) var tokenType: String = ""
    private(set) var expiresIn: Int = Int.max
    
    // user
    private(set) var user: User = User()
    
    // other
    private(set) var isNewSignUp: Bool = false
    private(set) var scope: String = ""
}

extension AuthData: BasicMappable {
    
    mutating func sequence(map: Map) throws {
        try accessToken         <~ map["access_token"]
        try expiresIn           <~ map["expires_in"]
        try isNewSignUp         <~ map["new_signup"]
        try refreshToken        <~ map["refresh_token"]
        try scope               <~ map["scope"]
        try tokenType           <~ map["token_type"]
        try user                <~ map["user"]
    }
}
