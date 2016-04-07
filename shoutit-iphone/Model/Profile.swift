//
//  Profile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct Profile {
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
    
    static func profileWithUser(user: DetailedProfile) -> Profile {
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
                       isListening: nil,
                       listenersCount: user.listenersCount)
    }
}

extension Profile: Decodable {
    
    static func decode(j: JSON) -> Decoded<Profile> {
        let a =  curry(Profile.init)
            <^> j <| "id"
            <*> j <| "type"
            <*> j <| "api_url"
        let b = a
            <*> j <| "web_url"
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
    }
}

extension Profile: Encodable {
    
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
            ])
    }
}

extension Profile: Reportable {
    func attachedObjectJSON() -> JSON {
        return ["profile" : ["id" : self.id.encode()].encode()].encode()
    }
    
    func reportTitle() -> String {
        return NSLocalizedString("Report Profile", comment: "")
    }
}
