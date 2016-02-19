//
//  Shout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Shout: Decodable {
    
    let id: String
    let apiPath: String
    let webPath: String
    let image: String?
    let title: String
    let text: String
    let price: Double
    let currency: String
    let thumbnailPath: String?
    
    static func decode(j: JSON) -> Decoded<Shout> {
        let f = curry(Shout.init)
            <^> j <| "id"
            <*> j <| "api_url"
            <*> j <| "web_url"
            <*> j <|? "image"
            <*> j <| "title"
        return f
            <*> j <| "text"
            <*> j <| "price"
            <*> j <| "currency"
            <*> j <|? "thumbnail"
    }
    
}

enum ShoutType : String {
    case Offer = "offer"
    case Request = "request"
    case VideoCV = "cv-video"
}
