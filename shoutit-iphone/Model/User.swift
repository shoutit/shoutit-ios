//
//  User.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome
import PureJsonSerializer

struct User {
    
    // public profile
    let id: String
    let type: UserType
    let apiPath: String
    let webPath: String
    let username: String?
    let name: String?
    let firstName: String?
    let lastName: String?
    let activated: Bool
    let imagePath: String?
    let coverPath: String?
    let gender: Gender?
    let videoPath: String?
    let dateJoindedEpoch: Int
    let bio: String?
    let location: Address
    let email: String
    let website: String?
    let shoutsPath: String?
    let listenersCount: Int
    let listenersPath: String?
    let listeningMetadata: ListenersMetadata
    let listeningPath: String?
    let owner: Bool
    let pages: [User]?
    
    // app user specific
    let linkedAccounts: LoginAccounts?
    let pushTokens: PushTokens?
    let passwordSet: Bool?
}

extension User: MappableObject {
    
    init(map: Map) throws {
        id = try map.extract("id")
        type = try map.extract("type") {UserType(rawValue: $0)!}
        apiPath = try map.extract("api_url")
        webPath = try map.extract("web_url")
        username = try map.extract("username")
        name = try map.extract("name")
        firstName = try map.extract("first_name")
        lastName = try map.extract("last_name")
        activated = try map.extract("is_activated")
        imagePath = try map.extract("image")
        coverPath = try map.extract("cover")
        gender = try map.extract("gender") {Gender(string: $0)}
        videoPath = try map.extract("video")
        dateJoindedEpoch = try map.extract("date_joined")
        bio = try map.extract("bio")
        location = try map.extract("location")
        email = try map.extract("email")
        website = try map.extract("website")
        shoutsPath = try map.extract("shouts_url")
        listenersCount = try map.extract("listeners_count")
        listenersPath = try map.extract("listeners_url")
        listeningMetadata = try map.extract("listening_count")
        listeningPath = try map.extract("listening_url")
        owner = try map.extract("is_owner")
        pages = try map.extract("pages")
        linkedAccounts = try map.extract("linked_accounts")
        pushTokens = try map.extract("push_tokens")
        passwordSet = try map.extract("is_password_set")
    }
    
    func sequence(map: Map) throws {
        
        try id ~> map["id"]
        try type ~> map["type"]
            .transformToJson{$0.rawValue}
        try apiPath ~> map["api_url"]
        try webPath ~> map["web_url"]
        try username ~> map["username"]
        try name ~> map["name"]
        try firstName ~> map["first_name"]
        try lastName ~> map["last_name"]
        try activated ~> map["is_activated"]
        try imagePath ~> map["image"]
        try coverPath ~> map["cover"]
        try gender ~> map[KeyType.Key("gender")]
            .transformToJson{(gender) -> Json in
            if let raw = gender where raw != .Unknown {
                return .StringValue(raw.rawValue)
            }
            return .NullValue
        }
        
        try videoPath ~> map["video"]
        try dateJoindedEpoch ~> map["date_joined"]
        try bio ~> map["bio"]
        try location ~> map["location"]
        try email ~> map["email"]
        try website ~> map["website"]
        try shoutsPath ~> map["shouts_url"]
        try listenersCount ~> map["listeners_count"]
        try listenersPath ~> map["listeners_url"]
        try listeningMetadata ~> map["listening_count"]
        try listeningPath ~> map["listening_url"]
        try owner ~> map["is_owner"]
        try pages ~> map["pages"]
        try linkedAccounts ~> map["linked_accounts"]
        try pushTokens ~> map["push_tokens"]
        try passwordSet ~> map["is_password_set"]
    }
}

