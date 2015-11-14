//
//  SHTag.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHTag: Mappable {

    var name = String()
    var image = String()
    var url = String()
    var isListening: Bool?
    var listenersCount: Int = 0
    var shoutsCount: Int = 0
    var title = String()
    var rank: Int?
    var id: Int64?
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        name            <- map["name"]
        image           <- map["image"]
        url             <- map["url"]
        isListening     <- map["is_listening"]
        listenersCount  <- map["listeners_count"]
        shoutsCount     <- map["shouts_count"]
        title           <- map["title"]
        rank            <- map["rank"]
        id              <- map["id"]
    }
    
}
