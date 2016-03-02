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
    let firstName: String
    let lastName: String?
    let activated: Bool
    let imagePath: String?
    let coverPath: String?
    let listening: Bool?
    let listenersCount: Int
}

extension Profile: Decodable {
    
    static func decode(j: JSON) -> Decoded<Profile> {
        let a =  curry(Profile.init)
            <^> j <| "id"
            <*> j <| "type"
            <*> j <| "api_url"
            <*> j <| "web_url"
            <*> j <| "username"
        let b = a
            <*> j <| "name"
            <*> j <| "first_name"
            <*> j <|? "last_name"
            <*> j <| "is_activated"
        let c = b
            <*> j <|? "image"
            <*> j <|? "cover"
            <*> j <|? "is_listening"
            <*> j <| "listeners_count"
        return c
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
            "is_activated" : self.activated.encode(),
            "image" : self.imagePath.encode(),
            "cover" : self.coverPath.encode(),
            "is_listening" : self.listening.encode(),
            "listeners_count" : self.listenersCount.encode(),
            ])
    }
}

extension Profile: ProfileCollectionUser {
    var listeningMetadata: ListenersMetadata? { return nil }
    var bio: String { return "" }
    var website: String? { return nil }
    var dateJoinedEpoch_optional: Int? { return nil }
    var location_optional: Address? { return nil }
    var pages: [Profile]? { return nil }
}
