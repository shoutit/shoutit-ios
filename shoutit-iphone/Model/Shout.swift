//
//  Shout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct Shout: Decodable, Hashable, Equatable {
    
    // MARK: Basic fields
    public let id: String
    public let apiPath: String
    public let webPath: String
    public let typeString: String
    public let location: Address?
    public let title: String?
    public let text: String?
    public let price: Int?
    public let currency: String?
    public let thumbnailPath: String?
    public let videoPath: String?
    public let user: Profile?
    public let publishedAtEpoch: Int?
    public let category: Category
    public let tags: [Tag]?
    public let filters: [Filter]?
    
    // MARK: - Detail fields
    public let imagePaths: [String]?
    public let videos: [Video]?
    //let publishedOn: String?
    public let replyPath: String?
    public let relatedRequests: [Shout]?
    public let relatedOffers: [Shout]?
    public let conversations: [MiniConversation]?
    public let isMobileSet: Bool?
    public let mobile: String?
    public let promotion: Promotion?
    
    public let isBookmarked: Bool
    
    public static func decode(j: JSON) -> Decoded<Shout> {
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
            <*> j <|? "profile"
            <*> j <|? "date_published"
        let d = c
            <*> j <| "category"
            <*> j <||? "tags"
        let e = d
            <*> j <||? "filters"
        let f = e
            <*> j <||? "images"
            <*> j <||? "videos"
            <*> j <|? "reply_url"
        let g = f
            <*> j <||? "related_requests"
            <*> j <||? "related_offers"
            <*> j <||? "conversations"
            <*> j <|? "is_mobile_set"
        let h = g
            <*> j <|? "mobile"
            <*> j <|? "promotion"
            <*> j <| "is_bookmarked"
        return h
    }
    
    
    public var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    public func type() -> ShoutType? {
        return ShoutType(rawValue: self.typeString)
    }
    
}

extension Shout: Encodable {
    public func encode() -> JSON {
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

public extension Shout {
    
    public func priceText() -> String? {
        if let price = self.price {
            return NumberFormatters.priceStringWithPrice(price)
        }
        
        return nil
    }
    
    public func priceTextWithoutFree() -> String? {
        if let price = self.price {
            if price == 0 {
                return "0"
            }
            
            return NumberFormatters.priceStringWithPrice(price)
        }
        
        return nil
    }
}

public extension Shout {
    
    public var isPromoted: Bool {
        return promotion != nil
    }
}

extension Shout: Reportable {
    public func attachedObjectJSON() -> JSON {
        return ["shout" : ["id" : self.id.encode()].encode()].encode()
    }
    
    public func reportTitle() -> String {
        return NSLocalizedString("Report Shout", comment: "")
    }
}

public func ==(lhs: Shout, rhs: Shout) -> Bool {
    return lhs.id == rhs.id
}

public enum ShoutType : String {
    case Offer = "offer"
    case Request = "request"
    
    public func title() -> String {
        switch self {
        case .Offer: return NSLocalizedString("Offer", comment: "")
        case .Request: return NSLocalizedString("Request", comment: "")
        }
    }
}

public extension Shout {
    public func copyShoutWithPromotion(newPromotion: Promotion) -> Shout {
        return Shout(id: self.id, apiPath: self.apiPath, webPath: self.webPath, typeString: self.typeString, location: self.location, title: self.title, text: self.text, price: self.price, currency: self.currency, thumbnailPath: self.thumbnailPath, videoPath: self.videoPath, user: self.user, publishedAtEpoch: self.publishedAtEpoch, category: self.category, tags: self.tags, filters: self.filters, imagePaths: self.imagePaths, videos: self.videos, replyPath: self.replyPath, relatedRequests: self.relatedRequests, relatedOffers: self.relatedOffers, conversations: self.conversations, isMobileSet: self.isMobileSet, mobile: self.mobile, promotion: newPromotion, isBookmarked: self.isBookmarked)
    }
    
    public func copyWithBookmark(bookmarked: Bool) -> Shout? {
        return Shout(id: self.id, apiPath: self.apiPath, webPath: self.webPath, typeString: self.typeString, location: self.location, title: self.title, text: self.text, price: self.price, currency: self.currency, thumbnailPath: self.thumbnailPath, videoPath: self.videoPath, user: self.user, publishedAtEpoch: self.publishedAtEpoch, category: self.category, tags: self.tags, filters: self.filters, imagePaths: self.imagePaths, videos: self.videos, replyPath: self.replyPath, relatedRequests: self.relatedRequests, relatedOffers: self.relatedOffers, conversations: self.conversations, isMobileSet: self.isMobileSet, mobile: self.mobile, promotion: self.promotion, isBookmarked: bookmarked)
    }
}
