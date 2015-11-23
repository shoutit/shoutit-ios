//
//  SHShout.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

enum ShoutType : String {
    case Offer = "offer"
    case Request = "request"
    case VideoCV = "cvRequest"
}

class SHShout: Mappable {
    
    var id = String()
    var apiUrl = String()
    var webUrl = String()
    var type: ShoutType?
    var location: SHAddress?
    var title = String()
    var text =  String()
    var price: Double = 0.0
    var currency = String()
    var thumbnail = String()
    var videoUrl = String()
    var user: SHUser?
    var datePublished: Double = 0.0
    var category: SHCategory?
    var tags: [SHTag]?
    var stringTags: [String] = []
    
    required init?(_ map: Map) {
        
    }
    
    init(){}
    
    // Mappable
    func mapping(map: Map) {
        id              <- map["id"]
        apiUrl          <- map["api_url"]
        webUrl          <- map["web_url"]
        location        <- map["location"]
        type            <- map["type"]
        title           <- map["title"]
        text            <- map["text"]
        price           <- map["price"]
        currency        <- map["currency"]
        thumbnail       <- map["thumbnail"]
        videoUrl        <- map["video_url"]
        user            <- map["user"]
        datePublished   <- map["date_published"]
        category        <- map["category"]
        tags            <- map["tags"]
    }
    
    func getStringTags() -> [String] {
        // TODO
        return []
    }
    
}
