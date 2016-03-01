//
//  DetailedProfile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct DetailedProfile {
    
    let id: String
    let type: UserType
    let apiPath: String
    let webPath: String
    let username: String
    let name: String
    let firstName: String?
    let lastName: String?
    let activated: Bool
    let imagePath: String?
    let coverPath: String?
    let isListening: Bool
    let listenersCount: Int
    let gender: Gender?
    let videoPath: Video?
    let dateJoinedEpoch: Int
    let bio: String
    let location: Address
    let email: String
    let website: String?
    let linkedAccounts: LoginAccounts?
    let pushTokens: PushTokens?
    let isPasswordSet: Bool?
    let isListener: Bool?
    let shoutsPath: String?
    let listenersPath: String
    let listeningMetadata: ListenersMetadata?
    let listeningPath: String?
    let owner: Bool
    let messagePath: String?
    let pages: [Profile]?
    let admins: [Profile]?
}

extension DetailedProfile: Decodable {
    
    static func decode(j: JSON) -> Decoded<DetailedProfile> {
        let a =  curry(DetailedProfile.init)
            <^> j <| "id"
            <*> j <| "type"
            <*> j <| "api_url"
            <*> j <| "web_url"
            <*> j <| "username"
        let b = a
            <*> j <| "name"
            <*> j <|? "first_name"
            <*> j <|? "last_name"
            <*> j <| "is_activated"
        let c = b
            <*> j <|? "image"
            <*> j <|? "cover"
            <*> j <| "is_listening"
            <*> j <| "listeners_count"
            <*> j <|? "gender"
            <*> j <|? "video"
        let d = c
            <*> j <| "date_joined"
            <*> j <| "bio"
            <*> j <| "location"
            <*> j <| "email"
        let e = d
            <*> j <|? "website"
            <*> j <|? "linked_accounts"
            <*> j <|? "push_tokens"
            <*> j <|? "is_password_set"
            <*> j <|? "is_listener"
            <*> j <|? "shouts_url"
            <*> j <| "listeners_url"
        let f = e
            <*> j <|? "listening_count"
            <*> j <|? "listening_url"
            <*> j <| "is_owner"
            <*> j <|? "message_url"
            <*> j <||? "pages"
            <*> j <||? "admins"
        return f
    }
}

