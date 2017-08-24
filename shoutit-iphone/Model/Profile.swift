//
//  Profile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable
public struct Profile {
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
    public let location: Address?
    public let stats: ProfileStats?
    
    public static func profileWithUser(_ user: DetailedProfile) -> Profile {
        var stats : ProfileStats?
        
        if let detailedUser = user as? DetailedUserProfile {
            stats = detailedUser.stats
        }
        
        return Profile(id: user.id,
                       type: user.type,
                       apiPath: user.apiPath,
                       webPath: user.webPath,
                       username: user.username,
                       name: user.name,
                       firstName: user.firstName,
                       lastName: user.lastName,
                       isActivated: user.isActivated,
                       imagePath: user.imagePath,
                       coverPath: user.coverPath,
                       isListening: user.isListening,
                       listenersCount: 0,
                       location: user.location,
                       stats:  stats
                )
    }
    
    public static func profileWithGuest(_ guest: GuestUser) -> Profile {
        return Profile(id: guest.id,
                       type: .User,
                       apiPath: guest.apiPath,
                       webPath: nil,
                       username: guest.username,
                       name: guest.username,
                       firstName: nil,
                       lastName: nil,
                       isActivated: false,
                       imagePath: nil,
                       coverPath: nil,
                       isListening: nil,
                       listenersCount: 0,
                       location: guest.location,
                       stats: nil)
    }
}

extension Profile {
    public func fullName() -> String {
        if self.type == .User {
            return "\(firstName ?? "") \(lastName ?? "")"
        }
        
        return self.username
    }
}

extension Profile: JSONCodable {
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
        location = try decoder.decode("location")
        stats = try decoder.decode("stats")
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
            try encoder.encode(location, key: "location")
            try encoder.encode(stats, key: "stats")
        })
    }
}

extension Profile {
    public func copyWithListnersCount(_ newListnersCount: Int, isListening: Bool? = nil) -> Profile {
        return Profile(id: self.id, type: self.userType, apiPath: self.apiPath, webPath: self.webPath, username: self.username, name: self.name, firstName: self.firstName, lastName: self.lastName, isActivated: self.isActivated, imagePath: self.imagePath, coverPath: self.coverPath, isListening: isListening != nil ? isListening : self.isListening, listenersCount: newListnersCount, location: self.location, stats: self.stats)
    }
}

extension Profile: Reportable {
    public var reportTypeKey: String {
        return "profile"
    }
    
    public func reportTitle() -> String {
        return NSLocalizedString("Report Profile", comment: "Report Title")
    }
}
