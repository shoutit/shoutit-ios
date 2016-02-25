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

struct Shout: Decodable, Hashable, Equatable {
    
    let id: String
    let apiPath: String
    let webPath: String
    let image: String?
    let title: String
    
    let text: String
    let price: Double
    let currency: String
    let thumbnailPath: String?
    let category: Category
    
    let location: Address?
    let user: Profile
    let videoPath: String?
    let typeString: String
    let publishedAt: Int?
    
    static func decode(j: JSON) -> Decoded<Shout> {
        let a = curry(Shout.init)
            <^> j <| "id"
            <*> j <| "api_url"
            <*> j <| "web_url"
            <*> j <|? "image"
            <*> j <| "title"
        let b = a
            <*> j <| "text"
            <*> j <| "price"
            <*> j <| "currency"
            <*> j <|? "thumbnail"
            <*> j <| "category"
        let c = b
            <*> j <|? "location"
            <*> j <| "user"
            <*> j <|? "video_url"
            <*> j <| "type"
            <*> j <|? "date_published"
        
        return c
    }
    
    var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    func type() -> ShoutType? {
        return ShoutType(rawValue: self.typeString)
    }
    
}

func ==(lhs: Shout, rhs: Shout) -> Bool {
    return lhs.id == rhs.id
}

enum ShoutType : String {
    case Offer = "offer"
    case Request = "request"
    case VideoCV = "cv-video"
}
