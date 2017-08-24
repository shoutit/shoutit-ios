//
//  LoginAccounts.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct LoginAccounts {
    public let facebook: FacebookAccount?
    public let gplus: GoogleAccount?
    public let facebookPage: FacebookPage?
}

extension LoginAccounts: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        facebook = try decoder.decode("facebook")
        gplus = try decoder.decode("gplus")
        facebookPage = try decoder.decode("facebook_page")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(facebook, key: "facebook")
            try encoder.encode(gplus, key: "gplus")
            try encoder.encode(facebookPage, key: "facebook_page")
            
        })
    }
}
