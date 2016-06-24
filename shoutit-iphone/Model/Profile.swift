//
//  Profile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

import Ogra

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
    
    public static func profileWithUser(user: DetailedProfile) -> Profile {
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
                       listenersCount: user.listenersCount,
                       location: user.location,
                       stats:  user.stats
                )
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

extension Profile: Decodable {
    
    public static func decode(j: JSON) -> Decoded<Profile> {
        let a =  curry(Profile.init)
            <^> j <| "id"
            <*> j <| "type"
            <*> j <| "api_url"
        let b = a
            <*> j <|? "web_url"
            <*> j <| "username"
            <*> j <| "name"
            <*> j <|? "first_name"
            <*> j <|? "last_name"
        let c = b
            <*> j <| "is_activated"
            <*> j <|? "image"
            <*> j <|? "cover"
            <*> j <|? "is_listening"
        return c
            <*> j <| "listeners_count"
            <*> j <|? "location"
            <*> j <|? "stats"
    }
}

extension Profile: Encodable {
    
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
            "location" : self.location.encode(),
            "stats" : self.stats.encode()
            ])
    }
}

extension Profile: Reportable {
    public func attachedObjectJSON() -> JSON {
        return ["profile" : ["id" : self.id.encode()].encode()].encode()
    }
    
    public func reportTitle() -> String {
        return NSLocalizedString("Report Profile", comment: "")
    }
}
