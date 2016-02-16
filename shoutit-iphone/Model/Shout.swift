//
//  Shout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Freddy

public struct Shout {
    let id: String
    let apiPath: String
    let webPath: String
    let image: String?
    let title: String
    let text: String
    let price: Double
    let currency: String
    let thumnailPath: String?
    let videoPath: String?
    let datePublishedEpoch: Int
}

extension Shout: JSONDecodable {
    
    public init(json value: JSON) throws {
        id = try value.string("id")
        apiPath = try value.string("api_url")
        webPath = try value.string("web_url")
        title = try value.string("title")
        text = try value.string("text")
        price = try value.double("price")
        currency = try value.string("currency")
        thumnailPath = try value.string("thumbnail")
        videoPath = try value.string("video_url")
        datePublishedEpoch = try value.int("date_published")
        image = try value.string("image")
    }
}

enum ShoutType : String {
    case Offer = "offer"
    case Request = "request"
    case VideoCV = "cv-video"
}
