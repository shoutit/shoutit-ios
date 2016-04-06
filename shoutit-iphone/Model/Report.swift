//
//  Report.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 06/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct Report {
    let text: String
    let shout: Shout?
    let profile: Profile?
}

extension Report: Decodable {
    
    static func decode(j: JSON) -> Decoded<Report> {
        return curry(Report.init)
            <^> j <| "text"
            <*> j <|? "shout"
            <*> j <|? "profile"
    }
}

extension Report: Encodable {
    func encode() -> JSON {
        
        var json = [String: JSON]()
        
        json["text"] = self.text.encode()
        
        if let profile = profile {
            let profileId = ["id": profile.id.encode()]
            json["attached_object"] = ["profile": profileId.encode()].encode()
        }
        
        if let shout = shout {
            let shoutId = ["id": shout.id.encode()]
            json["attached_object"] = ["shout": shoutId.encode()].encode()
        }
        
        return JSON.Object(json)
    }
}