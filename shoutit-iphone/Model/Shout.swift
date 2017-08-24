//
//  Shout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable
public struct Shout: Hashable, Equatable {
    
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
    
    public let isBookmarked: Bool?
    public let isLiked: Bool?
    
    public var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    public func type() -> ShoutType? {
        return ShoutType(rawValue: self.typeString)
    }
    
}

extension Shout: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        apiPath = try decoder.decode("api_url")
        webPath = try decoder.decode("web_url")
        typeString = try decoder.decode("type")
        location = try decoder.decode("location")
        title = try decoder.decode("title")
        text = try decoder.decode("text")
        price = try decoder.decode("price")
        currency = try decoder.decode("currency")
        thumbnailPath = try decoder.decode("thumbnail")
        videoPath = try decoder.decode("video_url")
        user = try decoder.decode("profile")
        category = try decoder.decode("category")
        tags = try decoder.decode("tags")
        publishedAtEpoch = try decoder.decode("date_published")
        filters = try decoder.decode("filters")
        imagePaths = try decoder.decode("images")
        videos = try decoder.decode("videos")
        replyPath = try decoder.decode("reply_url")
        relatedRequests = try decoder.decode("related_requests")
        relatedOffers = try decoder.decode("related_offers")
        conversations = try decoder.decode("conversations")
        isMobileSet = try decoder.decode("is_mobile_set")
        mobile = try decoder.decode("mobile")
        promotion = try decoder.decode("promotion")
        isBookmarked = try decoder.decode("is_bookmarked")
        isLiked = try decoder.decode("is_liked")
        
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(apiPath, key: "api_url")
            try encoder.encode(webPath, key: "web_url")
            try encoder.encode(typeString, key: "type")
            try encoder.encode(title, key: "title")
            try encoder.encode(text, key: "text")
            try encoder.encode(price, key: "price")
            try encoder.encode(user, key: "profile")
        })
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
    public var reportTypeKey: String {
        return "shout"
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
    public func copyShoutWithPromotion(_ newPromotion: Promotion) -> Shout {
        return Shout(id: self.id, apiPath: self.apiPath, webPath: self.webPath, typeString: self.typeString, location: self.location, title: self.title, text: self.text, price: self.price, currency: self.currency, thumbnailPath: self.thumbnailPath, videoPath: self.videoPath, user: self.user, publishedAtEpoch: self.publishedAtEpoch, category: self.category, tags: self.tags, filters: self.filters, imagePaths: self.imagePaths, videos: self.videos, replyPath: self.replyPath, relatedRequests: self.relatedRequests, relatedOffers: self.relatedOffers, conversations: self.conversations, isMobileSet: self.isMobileSet, mobile: self.mobile, promotion: newPromotion, isBookmarked: self.isBookmarked, isLiked: self.isLiked)
    }
    
    public func copyWithBookmark(_ bookmarked: Bool) -> Shout? {
        return Shout(id: self.id, apiPath: self.apiPath, webPath: self.webPath, typeString: self.typeString, location: self.location, title: self.title, text: self.text, price: self.price, currency: self.currency, thumbnailPath: self.thumbnailPath, videoPath: self.videoPath, user: self.user, publishedAtEpoch: self.publishedAtEpoch, category: self.category, tags: self.tags, filters: self.filters, imagePaths: self.imagePaths, videos: self.videos, replyPath: self.replyPath, relatedRequests: self.relatedRequests, relatedOffers: self.relatedOffers, conversations: self.conversations, isMobileSet: self.isMobileSet, mobile: self.mobile, promotion: self.promotion, isBookmarked: bookmarked, isLiked: self.isLiked)
    }
    
    public func copyWithLiked(_ liked: Bool) -> Shout? {
        return Shout(id: self.id, apiPath: self.apiPath, webPath: self.webPath, typeString: self.typeString, location: self.location, title: self.title, text: self.text, price: self.price, currency: self.currency, thumbnailPath: self.thumbnailPath, videoPath: self.videoPath, user: self.user, publishedAtEpoch: self.publishedAtEpoch, category: self.category, tags: self.tags, filters: self.filters, imagePaths: self.imagePaths, videos: self.videos, replyPath: self.replyPath, relatedRequests: self.relatedRequests, relatedOffers: self.relatedOffers, conversations: self.conversations, isMobileSet: self.isMobileSet, mobile: self.mobile, promotion: self.promotion, isBookmarked: self.isBookmarked, isLiked: liked)
    }
}
