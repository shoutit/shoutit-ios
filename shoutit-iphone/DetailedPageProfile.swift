//
//  DetailedPageProfile.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 11/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

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
    public let linkedAccounts: LoginAccounts?
    
    public init(id: String, type: UserType, apiPath: String, webPath: String?, username: String, name: String, firstName: String?, lastName: String?, isActivated: Bool, isVerified: Bool, imagePath: String?, coverPath: String?, isListening: Bool?, listnersCount: Int, website: String?, about: String?, isPublished: Bool?, stats: ProfileStats?, mobile: String?, founded: String?, description: String?, impressum: String?, overview: String?, mission: String?, general_info: String?, listeningMetadata: ListenersMetadata?, dateJoinedEpoch: Int, location: Address, pushTokens: PushTokens?, admin: Box<DetailedUserProfile>?, linkedAccounts: LoginAccounts?) {
        self.id = id
        self.type = type
        self.apiPath = apiPath
        self.webPath = webPath
        self.username = username
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.isActivated = isActivated
        self.isVerified = isVerified
        self.isPublished = isPublished
        self.stats = stats
        self.mobile = mobile
        self.founded = founded
        self.listeningMetadata = listeningMetadata
        self.dateJoinedEpoch = dateJoinedEpoch
        self.location = location
        self.imagePath = imagePath
        self.coverPath = coverPath
        self.isListening = isListening
        self.listenersCount = listnersCount
        self.website = website
        self.pushTokens = pushTokens
        self.admin = admin
        self.about = about
        self.description = description
        self.impressum = impressum
        self.overview = overview
        self.mission = mission
        self.general_info = general_info
        self.linkedAccounts = linkedAccounts
    }
}

extension DetailedPageProfile: JSONCodable {
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
        isVerified = try decoder.decode("is_verified")
        imagePath = try decoder.decode("image")
        coverPath = try decoder.decode("cover")
        isListening = try decoder.decode("is_listening")
        listenersCount = try decoder.decode("listeners_count")
        website = try decoder.decode("website")
        about = try decoder.decode("about")
        isPublished = try decoder.decode("is_published")
        stats = try decoder.decode("stats")
        mobile = try decoder.decode("phone")
        founded = try decoder.decode("founded")
        description = try decoder.decode("description")
        impressum = try decoder.decode("impressum")
        overview = try decoder.decode("overview")
        mission = try decoder.decode("mission")
        general_info = try decoder.decode("general_info")
        listeningMetadata = try decoder.decode("listening_count")
        dateJoinedEpoch = try decoder.decode("date_joined")
        location = try decoder.decode("location")
        pushTokens = try decoder.decode("push_tokens")
        admin = try decoder.decode("admin")
        linkedAccounts = try decoder.decode("linked_accounts")
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
            try encoder.encode(isVerified, key: "is_verified")
            try encoder.encode(imagePath, key: "image")
            try encoder.encode(coverPath, key: "cover")
            try encoder.encode(isListening, key: "is_listening")
            try encoder.encode(listenersCount, key: "listeners_count")
            try encoder.encode(website, key: "website")
            try encoder.encode(about, key: "about")
            try encoder.encode(isPublished, key: "is_published")
            try encoder.encode(stats, key: "stats")
            try encoder.encode(mobile, key: "phone")
            try encoder.encode(founded, key: "founded")
            try encoder.encode(description, key: "description")
            try encoder.encode(impressum, key: "impressum")
            try encoder.encode(overview, key: "overview")
            try encoder.encode(mission, key: "mission")
            try encoder.encode(general_info, key: "general_info")
            try encoder.encode(listeningMetadata, key: "listening_count")
            try encoder.encode(dateJoinedEpoch, key: "date_joined")
            try encoder.encode(location, key: "location")
            try encoder.encode(pushTokens, key: "push_tokens")
            try encoder.encode(admin, key: "admin")
            try encoder.encode(linkedAccounts, key: "linked_accounts")
            
        })
    }
}

extension DetailedPageProfile {
    public func updatedProfileWithStats(_ stts: ProfileStats?) -> DetailedPageProfile {
        return DetailedPageProfile(id: self.id, type: self.type, apiPath: self.apiPath, webPath: self.webPath, username: self.username, name: self.name, firstName: self.firstName, lastName: self.lastName, isActivated: self.isActivated, isVerified: self.isVerified, imagePath: self.imagePath, coverPath: self.coverPath, isListening: self.isListening, listnersCount: self.listenersCount, website: self.website, about: self.about, isPublished: self.isPublished, stats: stts, mobile: self.mobile, founded: self.founded, description: self.description, impressum: self.impressum, overview: self.overview, mission: self.mission, general_info: self.general_info, listeningMetadata: self.listeningMetadata, dateJoinedEpoch: self.dateJoinedEpoch, location: self.location, pushTokens: self.pushTokens, admin: self.admin, linkedAccounts: self.linkedAccounts)
    }
    
    public func updatedProfileWithNewListnersCount(_ lstCount: Int, isListening: Bool? = nil) -> DetailedPageProfile {
        return DetailedPageProfile(id: self.id, type: self.type, apiPath: self.apiPath, webPath: self.webPath, username: self.username, name: self.name, firstName: self.firstName, lastName: self.lastName, isActivated: self.isActivated, isVerified: self.isVerified, imagePath: self.imagePath, coverPath: self.coverPath, isListening: isListening != nil ? isListening : self.isListening, listnersCount: lstCount, website: self.website, about: self.about, isPublished: self.isPublished, stats: self.stats, mobile: self.mobile, founded: self.founded, description: self.description, impressum: self.impressum, overview: self.overview, mission: self.mission, general_info: self.general_info, listeningMetadata: self.listeningMetadata, dateJoinedEpoch: self.dateJoinedEpoch, location: self.location, pushTokens: self.pushTokens, admin: self.admin, linkedAccounts: self.linkedAccounts)
    }
}
