//
//  User.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct User {
    
    // public profile
    let id: String
    let type: UserType
    let apiPath: String
    let webPath: String
    let username: String
    let name: String?
    let firstName: String?
    let lastName: String?
    let activated: Bool
    let imagePath: String?
    let coverPath: String?
    let gender: Gender?
    let videoPath: String?
    let dateJoindedEpoch: Int?
    let bio: String?
    let location: Address?
    let email: String?
    let website: String?
    let shoutsPath: String?
    let listenersCount: Int
    let listenersPath: String?
    let listeningMetadata: ListenersMetadata?
    let listeningPath: String?
    let owner: Bool?
    let pages: [Profile]?
    
    // app user specific
    let linkedAccounts: LoginAccounts?
    let pushTokens: PushTokens?
    let passwordSet: Bool?
}

extension User: Decodable {
    
    static func decode(j: JSON) -> Decoded<User> {
        let a = curry(User.init)
            <^> j <| "id"
            <*> j <| "type"
            <*> j <| "api_url"
            <*> j <| "web_url"
            <*> j <| "username"
        let b = a
            <*> j <|? "name"
            <*> j <|? "first_name"
            <*> j <|? "last_name"
            <*> j <| "is_activated"
        let c = b
            <*> j <|? "image"
            <*> j <|? "cover"
            <*> j <|? "gender"
            <*> j <|? "video"
        let d = c
            <*> j <|? "date_joined"
            <*> j <|? "bio"
            <*> j <|? "location"
            <*> j <|? "email"
        let e = d
            <*> j <|? "website"
            <*> j <|? "shouts_url"
            <*> j <| "listeners_count"
            <*> j <|? "listeners_url"
        let f = e
            <*> j <|? "listening_count"
            <*> j <|? "listening_url"
            <*> j <|? "is_owner"
            <*> j <||? "pages"
        let g = f
            <*> j <|? "linked_accounts"
            <*> j <|? "push_tokens"
            <*> j <|? "is_password_set"
        
        return g
    }
}

extension User: Encodable {
    
    func encode() -> JSON {
        return JSON.Object([
            "id" : self.id.encode(),
            "type" : self.type.encode(),
            "api_url" : self.apiPath.encode(),
            "web_url" : self.webPath.encode(),
            "username" : self.username.encode(),
            "name" : self.name.encode(),
            "first_name" : self.firstName.encode(),
            "last_name" : self.lastName.encode(),
            "is_activated" : self.activated.encode(),
            "image" : self.imagePath.encode(),
            "cover" : self.coverPath.encode(),
            "gender" : self.gender.encode(),
            "video" : self.videoPath.encode(),
            "date_joined" : self.dateJoindedEpoch.encode(),
            "bio" : self.bio.encode(),
            "location" : self.location.encode(),
            "email" : self.email.encode(),
            "website" : self.website.encode(),
            "shouts_url" : self.shoutsPath.encode(),
            "listeners_count" : self.listenersCount.encode(),
            "listeners_url" : self.listenersPath.encode(),
            "listening_count" : self.listeningMetadata.encode(),
            "listening_url" : self.listeningPath.encode(),
            "is_owner" : self.owner.encode(),
            "pages" : self.pages.encode(),
            "linked_accounts" : self.linkedAccounts.encode(),
            "push_tokens" : self.pushTokens.encode(),
            "is_password_set" : self.passwordSet.encode()
            ])
    }
}

