//
//  DetailedPageProfile.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 11/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct DetailedPageProfile: DetailedProfile {
    
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
    public let isVerified: Bool
    public let imagePath: String?
    public let coverPath: String?
    public let isListening: Bool?
    public let listenersCount: Int
    public let website: String?
    public let about: String?
    public let isPublished: Bool?
    public let stats: ProfileStats?
    public let mobile: String?
    public let founded: String?
    public let description: String?
    public let impressum: String?
    public let overview: String?
    public let mission: String?
    public let general_info: String?
    public let listeningMetadata: ListenersMetadata?
    
    public var dateJoinedEpoch: Int
    public var location: Address
    public var pushTokens: PushTokens?
    
    public let admin: Box<DetailedUserProfile>?
}



extension DetailedPageProfile: Decodable {
    
    public static func decode(j: JSON) -> Decoded<DetailedPageProfile> {
        let a =  curry(DetailedPageProfile.init)
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
            <*> j <| "is_verified"
            <*> j <|? "image"
            <*> j <|? "cover"
            <*> j <|? "is_listening"
        let d = c
            <*> j <| "listeners_count"
            <*> j <|? "website"
            <*> j <|? "about"
        let e = d
            <*> j <|? "is_published"
            <*> j <|? "stats"
            <*> j <|? "phone"
            <*> j <|? "founded"
        let f = e
            <*> j <|? "description"
            <*> j <|? "impressum"
            <*> j <|? "overview"
        let g = f
            <*> j <|? "mission"
            <*> j <|? "general_info"
            <*> j <|? "listening_count"
        let h = g
            <*> j <| "date_joined"
            <*> j <| "location"
            <*> j <|? "push_tokens"
            <*> j <|? "admin"
        return h
    }
}

extension DetailedPageProfile {
    
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
            "is_verified" : self.isVerified.encode(),
            "image" : self.imagePath.encode(),
            "cover" : self.coverPath.encode(),
            "is_listening" : self.isListening.encode(),
            "listeners_count" : self.listenersCount.encode(),
            "website" : self.website.encode(),
            "about" : self.about.encode(),
            "is_published" : self.isPublished.encode(),
            "stats" : self.stats.encode(),
            "phone" : self.mobile.encode(),
            "founded" : self.founded.encode(),
            "description" : self.description.encode(),
            "impressum" : self.impressum.encode(),
            "overview" : self.overview.encode(),
            "mission" : self.mission.encode(),
            "general_info" : self.general_info.encode(),
            "admin" : self.admin.encode(),
            "listening_count" : self.listeningMetadata.encode(),
            "date_joined" : self.dateJoinedEpoch.encode(),
            "location" : self.location.encode(),
            ])
    }
}
