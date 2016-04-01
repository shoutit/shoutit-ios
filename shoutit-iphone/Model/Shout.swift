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
import Ogra

struct Shout: Decodable, Hashable, Equatable {
    
    // MARK: Basic fields
    let id: String
    let apiPath: String
    let webPath: String
    let typeString: String
    let location: Address?
    let title: String?
    let text: String?
    let price: Int?
    let currency: String?
    let thumbnailPath: String?
    let videoPath: String?
    let user: Profile
    let publishedAtEpoch: Int?
    let category: Category
    let tags: [Tag]?
    let filters: [Filter]?
    
    // MARK: - Detail fields
    let imagePaths: [String]?
    let videos: [Video]?
    //let publishedOn: String?
    let replyPath: String?
    let relatedRequests: [Shout]?
    let relatedOffers: [Shout]?
    let conversations: [Conversation]?
    let isMobileSet: Bool?
    
    static func decode(j: JSON) -> Decoded<Shout> {
        let a = curry(Shout.init)
            <^> j <| "id"
            <*> j <| "api_url"
            <*> j <| "web_url"
            <*> j <| "type"
            <*> j <|? "location"
        let b = a
            <*> j <|? "title"
            <*> j <|? "text"
            <*> j <|? "price"
            <*> j <|? "currency"
        let c = b
            <*> j <|? "thumbnail"
            <*> j <|? "video_url"
            <*> j <| "profile"
            <*> j <|? "date_published"
        let d = c
            <*> j <| "category"
            <*> j <||? "tags"
            <*> j <||? "filters"
        let e = d
            <*> j <||? "images"
            <*> j <||? "videos"
            //<*> j <|? "published_on"
            <*> j <|? "reply_url"
        let f = e
            <*> j <||? "related_requests"
            <*> j <||? "related_offers"
            <*> j <||? "conversations"
            <*> j <|? "is_mobile_set"
        return f
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

extension Shout: Encodable {
    func encode() -> JSON {
        return JSON.Object(["id":self.id.encode(),
            "api_url":self.apiPath.encode(),
            "web_url":self.webPath.encode(),
            "type":self.typeString.encode(),
            "title":self.title.encode(),
            "text":self.text.encode(),
            "profile":self.user.encode(),
            "price": self.price.encode()
            ])
    }
}

extension Shout {
    func priceText() -> String? {
        if let price = self.price {
            return "\(price)"
        }
        
        return nil
    }
}

func ==(lhs: Shout, rhs: Shout) -> Bool {
    return lhs.id == rhs.id
}

enum ShoutType : String {
    case Offer = "offer"
    case Request = "request"
    case VideoCV = "cv-video"
    
    func title() -> String {
        switch self {
        case .Offer: return NSLocalizedString("Offer", comment: "")
        case .Request: return NSLocalizedString("Request", comment: "")
        default: return ""
        }
    }
}
