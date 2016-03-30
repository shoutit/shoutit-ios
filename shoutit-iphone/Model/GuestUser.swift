//
//  GuestUser.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct GuestUser: User {
    
    let id: String
    let type: UserType
    let isGuest: Bool
    let apiPath: String
    let username: String
    let dateJoinedEpoch: Int
    let location: Address
    let pushTokens: PushTokens?
}

extension GuestUser: Decodable {
    
    static func decode(j: JSON) -> Decoded<GuestUser> {
        let a = curry(GuestUser.init)
            <^> j <| "id"
            <*> j <| "type"
            <*> j <| "is_guest"
            <*> j <| "api_url"
            <*> j <| "username"
        let b = a
            <*> j <| "date_joined"
            <*> j <| "location"
            <*> j <|? "push_tokens"
        return b
    }
}

extension GuestUser {
    
    func encode() -> JSON {
        return JSON.Object([
            "id" : self.id.encode(),
            "type" : self.type.encode(),
            "is_guest" : self.isGuest.encode(),
            "api_url" : self.apiPath.encode(),
            "username" : self.username.encode(),
            "date_joined" : self.dateJoinedEpoch.encode(),
            "location" : self.location.encode(),
            "push_tokens" : self.pushTokens.encode(),
            ])
    }
}