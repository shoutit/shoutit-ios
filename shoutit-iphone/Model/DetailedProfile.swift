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

struct DetailedProfile: User {
    
    var isGuest: Bool {
        return false
    }
    
    let id: String
    let type: UserType
    let apiPath: String
    let webPath: String
    let username: String
    let name: String
    let firstName: String?
    let lastName: String?
    let isActivated: Bool
    let imagePath: String?
    let coverPath: String?
    let isListening: Bool?
    let listenersCount: Int
    let gender: Gender?
    let video: Video?
    let dateJoinedEpoch: Int
    let bio: String?
    let about: String?
    let location: Address
    let email: String?
    let mobile: String?
    let website: String?
    let linkedAccounts: LoginAccounts?
    let pushTokens: PushTokens?
    let isPasswordSet: Bool?
    let isListener: Bool?
    let shoutsPath: String?
    let listenersPath: String
    let listeningMetadata: ListenersMetadata?
    let listeningPath: String?
    let isOwner: Bool
    let chatPath: String?
    let pages: [Profile]?
    let admins: [Profile]?
    let conversation: Conversation?
}

extension DetailedProfile: Decodable {
    
    static func decode(j: JSON) -> Decoded<DetailedProfile> {
        let a =  curry(DetailedProfile.init)
            <^> j <| "id"
            <*> j <| "type"
            <*> j <| "api_url"
            <*> j <| "web_url"
        let b = a
            <*> j <| "username"
            <*> j <| "name"
            <*> j <|? "first_name"
            <*> j <|? "last_name"
        let c = b
            <*> j <| "is_activated"
            <*> j <|? "image"
            <*> j <|? "cover"
            <*> j <|? "is_listening"
        let d = c
            <*> j <| "listeners_count"
            <*> j <|? "gender"
            <*> j <|? "video"
            <*> j <| "date_joined"
            <*> j <|? "bio"
        let e = d
            <*> j <|? "about"
            <*> j <| "location"
            <*> j <|? "email"
            <*> j <|? "mobile"
            <*> j <|? "website"
        let f = e
            <*> j <|? "linked_accounts"
            <*> j <|? "push_tokens"
            <*> j <|? "is_password_set"
            <*> j <|? "is_listener"
        let g = f
            <*> j <|? "shouts_url"
            <*> j <| "listeners_url"
            <*> j <|? "listening_count"
            <*> j <|? "listening_url"
            <*> j <| "is_owner"
        let h = g
            <*> j <|? "chat_url"
            <*> j <||? "pages"
            <*> j <||? "admins"
            <*> j <|? "conversation" 
        return h
    }
}

extension DetailedProfile: Encodable {
    
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
            "is_activated" : self.isActivated.encode(),
            "image" : self.imagePath.encode(),
            "cover" : self.coverPath.encode(),
            "is_listening" : self.isListening.encode(),
            "listeners_count" : self.listenersCount.encode(),
            "gender" : self.gender.encode(),
            "video" : self.video.encode(),
            "date_joined" : self.dateJoinedEpoch.encode(),
            "bio" : self.bio.encode(),
            "about" : self.about.encode(),
            "location" : self.location.encode(),
            "email" : self.email.encode(),
            "mobile" : self.mobile.encode(),
            "website" : self.website.encode(),
            "linked_accounts" : self.linkedAccounts.encode(),
            "push_tokens" : self.pushTokens.encode(),
            "is_password_set" : self.isPasswordSet.encode(),
            "is_listener" : self.isListener.encode(),
            "shouts_url" : self.shoutsPath.encode(),
            "listeners_url" : self.listenersPath.encode(),
            "listening_count" : self.listeningMetadata.encode(),
            "listening_url" : self.listeningPath.encode(),
            "is_owner" : self.isOwner.encode(),
            "chat_url" : self.chatPath.encode(),
            "pages" : self.pages.encode(),
            "admins" : self.admins.encode()
            ])
    }
}
