//
//  DetailedProfile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct DetailedProfile: User {
    
    public var isGuest: Bool {
        return false
    }
    
    public let id: String
    public let type: UserType
    public let apiPath: String
    public let webPath: String?
    public let username: String
    public let name: String
    public let firstName: String?
    public let lastName: String?
    public let isActivated: Bool
    public let imagePath: String?
    public let coverPath: String?
    public let isListening: Bool?
    public let listenersCount: Int
    public let gender: Gender?
    public let video: Video?
    public let dateJoinedEpoch: Int
    public let bio: String?
    public let about: String?
    public let location: Address
    public let email: String?
    public let mobile: String?
    public let website: String?
    public let linkedAccounts: LoginAccounts?
    public let pushTokens: PushTokens?
    public let isPasswordSet: Bool?
    public let isListener: Bool?
    public let shoutsPath: String?
    public let listenersPath: String
    public let listeningMetadata: ListenersMetadata?
    public let listeningPath: String?
    public let isOwner: Bool
    public let chatPath: String?
    public let pages: [Profile]?
    public let admins: [Profile]?
    public let conversation: MiniConversation?
    public let stats: ProfileStats?
    public let birthday: Int?
}

extension DetailedProfile: Decodable {
    
    public static func decode(j: JSON) -> Decoded<DetailedProfile> {
        let a =  curry(DetailedProfile.init)
            <^> j <| "id"
            <*> j <| "type"
            <*> j <| "api_url"
            <*> j <|? "web_url"
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
            <*> j <|? "stats"
            <*> j <|? "birthday"
        return h
    }
}

extension DetailedProfile: Encodable {
    
    public func encode() -> JSON {
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
            "admins" : self.admins.encode(),
            "stats" : self.stats.encode(),
            "birthday" : self.birthday.encode()
            ])
    }
}


extension DetailedProfile {
    public func updatedProfileWithStats(stts: ProfileStats?) -> DetailedProfile {
        return DetailedProfile(id: self.id, type: self.type, apiPath: self.apiPath, webPath: self.webPath, username: self.username, name: self.name, firstName: self.firstName, lastName: self.lastName, isActivated: self.isActivated, imagePath: self.imagePath, coverPath: self.coverPath, isListening: self.isListening, listenersCount: self.listenersCount, gender: self.gender, video: self.video, dateJoinedEpoch: self.dateJoinedEpoch, bio: self.bio, about: self.about, location: self.location, email: self.email, mobile: self.mobile, website: self.website, linkedAccounts: self.linkedAccounts, pushTokens: self.pushTokens, isPasswordSet: self.isPasswordSet, isListener: self.isListener, shoutsPath: self.shoutsPath, listenersPath: self.listenersPath, listeningMetadata: self.listeningMetadata, listeningPath: self.listeningPath, isOwner: self.isOwner, chatPath: self.chatPath, pages: self.pages, admins: self.admins, conversation: self.conversation, stats: stts, birthday: self.birthday)
    }
}

extension DetailedProfile {
    func hasAllRequiredFieldsFilled() -> Bool {
        return (self.imagePath?.characters.count > 0) && (self.gender != nil) && (self.birthday != nil)
    }
}