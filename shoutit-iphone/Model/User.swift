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

enum UserType: String {
    case Profile = "Profile"
    case Page = "Page"
}

enum Gender: String {
    case Male = "male"
    case Female = "female"
}

struct User {
    
    // public profile
    private(set) var id: String = ""
    private(set) var type: UserType = .Profile
    private(set) var apiPath: String = ""
    private(set) var webPath: String = ""
    private(set) var username: String? = ""
    private(set) var name: String? = ""
    private(set) var firstName: String? = ""
    private(set) var lastName: String? = ""
    private(set) var activated: Bool = false
    private(set) var imagePath: String?
    private(set) var coverPath: String?
    private(set) var gender: Gender?
    private(set) var videoPath: String?
    private(set) var dateJoindedEpoch: Int = 0
    private(set) var bio: String?
    private(set) var location: Address = Address()
    private(set) var email: String = ""
    private(set) var website: String?
    private(set) var shoutsPath: String?
    private(set) var listenersCount: Int = 0
    private(set) var listenersPath: String?
    private(set) var listeningMetadata: ListenersMetadata = ListenersMetadata()
    private(set) var listeningPath: String?
    private(set) var owner: Bool = false
    private(set) var pages: [User]?
    
    // app user specific
    private(set) var linkedAccounts: LoginAccounts?
    private(set) var pushTokens: PushTokens?
    private(set) var passwordSet: Bool?
    
    // other user specific
    private(set) var listening: Bool?
}

extension User: BasicMappable {
    
    mutating func sequence(map: Map) throws {
        try id <~> map["id"]
        try type <~> map["type"].transformFromJson{UserType(rawValue: $0)!}.transformToJson{$0.rawValue}
        try apiPath <~> map["api_url"]
        try webPath <~> map["web_url"]
        try username <~> map["username"]
        try name <~> map["name"]
        try firstName <~> map["first_name"]
        try lastName <~> map["last_name"]
        try activated <~> map["is_activated"]
        try imagePath <~> map["image"]
        try coverPath <~> map["cover"]
        try gender <~> map["gender"].transformFromJson{Gender(rawValue: $0)!}.transformToJson{$0!.rawValue}
        try videoPath <~> map["video"]
        try dateJoindedEpoch <~> map["date_joined"]
        try bio <~> map["bio"]
        try location <~> map["location"]
        try email <~> map["email"]
        try website <~> map["website"]
        try shoutsPath <~> map["shouts_url"]
        try listenersCount <~> map["listeners_count"]
        try listenersPath <~> map["listeners_url"]
        try listeningMetadata <~> map["listening_count"]
        try listeningPath <~> map["listening_url"]
        try owner <~> map["is_owner"]
        try pages <~> map["pages"]
        
        // app user specific
        do {
            try linkedAccounts <~> map["linked_accounts"]
            try pushTokens <~> map["push_tokens"]
            try passwordSet <~> map["is_password_set"]
        } catch {
            print("other user")
        }
        
        do {
            try listening <~> map["is_listening"]
        } catch {
            print("app user")
        }
    }
}
