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
    
    var id: String?
    var apiUrl: String?
    var webUrl: String?
    var type: ShoutType = .Offer
    var location: SHAddress?
    var title = String()
    var text = String()
    var price: Double = 0.0
    var currency = String()
    var thumbnail: String?
    var videoUrl: String?
    var user: SHUser?
    var datePublished: NSDate?
    var category: SHCategory?
    var tags: [SHTag]?
    var stringTags: [String] = []
    var images:[String] = []
    var videos:[SHMedia] = []
    var replyUrl: String?
    var relatedRequests = []
    var relatedOffers = []
    var conversations = []
    
    required init?(_ map: Map) {
        
    }
    
    init() {
        self.location = SHAddress.getUserOrDeviceLocation()
        self.datePublished = NSDate()
    }
    
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
        datePublished   <- (map["date_published"], SHDateTransform())
        category        <- map["category"]
        tags            <- map["tags"]
        images          <- map["images"]
        videos          <- map["videos"]
        replyUrl        <- map["reply_url"]
        relatedRequests <- map["related_requests"]
        relatedOffers   <- map["relatedOffers"]
        conversations   <- map["conversations"]
    }
    
}
