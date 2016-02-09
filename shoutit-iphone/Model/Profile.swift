//
//  Profile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome
import PureJsonSerializer

struct Profile {
    
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
    let listening: Bool?
}

extension Profile: MappableObject {
    
    init(map: Map) throws {
        id = try map.extract("id")
        type = try map["type"].fromJson{UserType(rawValue: $0)!}
        apiPath = try map.extract("api_url")
        webPath = try map.extract("web_url")
        username = try map.extract("username")
        name = try map.extract("name")
        firstName = try map.extract("first_name")
        lastName = try map.extract("last_name")
        activated = try map.extract("is_activated")
        imagePath = try map.extract("image")
        coverPath = try map.extract("cover")
        listening = try map.extract("is_listening")
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
        try listening ~> map["is_listening"]
    }
}
