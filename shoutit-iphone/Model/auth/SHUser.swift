//
//  SHUser.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 04/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation
import ObjectMapper

class SHUser: Mappable {
    
    private(set) var apiUrl: String?
    private(set) var webUrl: String?
    private(set) var bio = String()
    private(set) var id = String()
    private(set) var location: SHAddress?
    private(set) var username: String?
    private(set) var name: String?
    private(set) var firstName: String?
    private(set) var lastName: String?
    private(set) var isActivated: Bool?
    private(set) var image: String?
    private(set) var isListening: Bool?
    
    required init?(_ map: Map) {
        
    }

    // Mappable
    func mapping(map: Map) {
        apiUrl              <- map["api_url"]
        webUrl              <- map["web_url"]
        username            <- map["username"]
        bio                 <- map["bio"]
        id                  <- map["id"]
        location            <- map["location"]
        name                <- map["name"]
        firstName           <- map["first_name"]
        lastName            <- map["last_name"]
        isActivated         <- map["is_activated"]
        image               <- map["image"]
        isListening         <- map["is_listening"]
    }
}
