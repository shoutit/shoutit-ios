//
//  Shout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome
import PureJsonSerializer

struct Shout {
    let id: String
    let apiPath: String
    let webPath: String
    let type: ShoutType
    let location: Address
    let title: String
    let text: String
    let price: Double
    let currency: String
    let thumnailPath: String?
    let videoPath: String?
    let user: Profile
    let datePublishedEpoch: Int
    let category: Category
    let tags: [Tag]
}

extension Shout: MappableObject {
    
    init(map: Map) throws {
        id = try map.extract("id")
        apiPath = try map.extract("api_url")
        webPath = try map.extract("web_url")
        type = try map["type"].fromJson{ShoutType(rawValue: $0)!}
        location = try map.extract("location")
        title = try map.extract("title")
        text = try map.extract("text")
        price = try map.extract("price")
        currency = try map.extract("currency")
        thumnailPath = try map.extract("thumbnail")
        videoPath = try map.extract("video_url")
        user = try map.extract("user")
        datePublishedEpoch = try map.extract("date_published")
        category = try map.extract("category")
        tags = try map.extract("tags")
    }
}

enum ShoutType : String {
    case Offer = "offer"
    case Request = "request"
    case VideoCV = "cv-video"
}
