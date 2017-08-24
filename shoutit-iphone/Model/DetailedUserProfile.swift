//
//  DetailedProfile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public struct DetailedUserProfile: DetailedProfile {
    
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
    public let conversation: MiniConversation?
    public let stats: ProfileStats?
    public let birthday: String?
}

extension DetailedUserProfile: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        type = try decoder.decode("type")
        apiPath = try decoder.decode("api_url")
        webPath = try decoder.decode("web_url")
        username = try decoder.decode("username")
        name = try decoder.decode("name")
        firstName = try decoder.decode("first_name")
        lastName = try decoder.decode("last_name")
        isActivated = try decoder.decode("is_activated")
        imagePath = try decoder.decode("image")
        coverPath = try decoder.decode("cover")
        isListening = try decoder.decode("is_listening")
        listenersCount = try decoder.decode("listeners_count")
        gender = try decoder.decode("gender")
        video = try decoder.decode("video")
        dateJoinedEpoch = try decoder.decode("date_joined")
        bio = try decoder.decode("bio")
        about = try decoder.decode("about")
        location = try decoder.decode("location")
        email = try decoder.decode("email")
        mobile = try decoder.decode("mobile")
        website = try decoder.decode("website")
        linkedAccounts = try decoder.decode("linked_accounts")
        pushTokens = try decoder.decode("push_tokens")
        isPasswordSet = try decoder.decode("is_password_set")
        isListener = try decoder.decode("is_listener")
        shoutsPath = try decoder.decode("shouts_url")
        listenersPath = try decoder.decode("listeners_url")
        listeningMetadata = try decoder.decode("listening_count")
        listeningPath = try decoder.decode("listening_url")
        isOwner = try decoder.decode("is_owner")
        chatPath = try decoder.decode("chat_url")
        conversation = try decoder.decode("conversation")
        stats = try decoder.decode("stats")
        birthday = try decoder.decode("birthday")
        
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(type, key: "type")
            try encoder.encode(apiPath, key: "api_url")
            try encoder.encode(webPath, key: "web_url")
            try encoder.encode(username, key: "username")
            try encoder.encode(name, key: "name")
            try encoder.encode(firstName, key: "first_name")
            try encoder.encode(lastName, key: "last_name")
            try encoder.encode(isActivated, key: "is_activated")
            try encoder.encode(coverPath, key: "cover")
            try encoder.encode(imagePath, key: "image")
            try encoder.encode(isListening, key: "is_listening")
            try encoder.encode(listenersCount, key: "listeners_count")
            try encoder.encode(gender, key: "gender")
            try encoder.encode(video, key: "video")
            try encoder.encode(dateJoinedEpoch, key: "date_joined")
            try encoder.encode(bio, key: "bio")
            try encoder.encode(about, key: "about")
            try encoder.encode(location, key: "location")
            try encoder.encode(email, key: "email")
            try encoder.encode(mobile, key: "mobile")
            try encoder.encode(website, key: "website")
            try encoder.encode(linkedAccounts, key: "linked_accounts")
            try encoder.encode(pushTokens, key: "push_tokens")
            try encoder.encode(isPasswordSet, key: "is_password_set")
            try encoder.encode(isListener, key: "is_listener")
            try encoder.encode(shoutsPath, key: "shouts_url")
            try encoder.encode(listenersPath, key: "listeners_url")
            try encoder.encode(listeningMetadata, key: "listening_count")
            try encoder.encode(listeningPath, key: "listening_url")
            try encoder.encode(isOwner, key: "is_owner")
            try encoder.encode(chatPath, key: "chat_url")
            try encoder.encode(conversation, key: "conversation")
            try encoder.encode(stats, key: "stats")
            try encoder.encode(birthday, key: "birthday")
        })
    }
}

extension DetailedUserProfile {
    public func updatedProfileWithStats(_ stts: ProfileStats?) -> DetailedUserProfile {
        return DetailedUserProfile(id: self.id, type: self.type, apiPath: self.apiPath, webPath: self.webPath, username: self.username, name: self.name, firstName: self.firstName, lastName: self.lastName, isActivated: self.isActivated, imagePath: self.imagePath, coverPath: self.coverPath, isListening: self.isListening, listenersCount: self.listenersCount, gender: self.gender, video: self.video, dateJoinedEpoch: self.dateJoinedEpoch, bio: self.bio, about: self.about, location: self.location, email: self.email, mobile: self.mobile, website: self.website, linkedAccounts: self.linkedAccounts, pushTokens: self.pushTokens, isPasswordSet: self.isPasswordSet, isListener: self.isListener, shoutsPath: self.shoutsPath, listenersPath: self.listenersPath, listeningMetadata: self.listeningMetadata, listeningPath: self.listeningPath, isOwner: self.isOwner, chatPath: self.chatPath, conversation: self.conversation, stats: stts, birthday: self.birthday)
    }
    
    public func updatedProfileWithNewListnersCount(_ lstCount: Int, isListening: Bool? = nil) -> DetailedUserProfile {
        return DetailedUserProfile(id: self.id, type: self.type, apiPath: self.apiPath, webPath: self.webPath, username: self.username, name: self.name, firstName: self.firstName, lastName: self.lastName, isActivated: self.isActivated, imagePath: self.imagePath, coverPath: self.coverPath, isListening: isListening != nil ? isListening : self.isListening, listenersCount: lstCount, gender: self.gender, video: self.video, dateJoinedEpoch: self.dateJoinedEpoch, bio: self.bio, about: self.about, location: self.location, email: self.email, mobile: self.mobile, website: self.website, linkedAccounts: self.linkedAccounts, pushTokens: self.pushTokens, isPasswordSet: self.isPasswordSet, isListener: self.isListener, shoutsPath: self.shoutsPath, listenersPath: self.listenersPath, listeningMetadata: self.listeningMetadata, listeningPath: self.listeningPath, isOwner: self.isOwner, chatPath: self.chatPath, conversation: self.conversation, stats: self.stats, birthday: self.birthday)
    }
}

extension DetailedUserProfile {
    public func hasAllRequiredFieldsFilled() -> Bool {
        return (self.imagePath?.characters.count > 0) && (self.gender != nil) && (self.birthday != nil)
    }
}
