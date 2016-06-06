//
//  MessageAttachment.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra
import CoreLocation

public enum MessageAttachmentType {
    case ShoutAttachment(shout: Shout)
    case LocationAttachment(location: MessageLocation)
    case ImageAttachment(path: String)
    case VideoAttachment(video: Video)
    case ProfileAttachment(profile: Profile)
}

public struct MessageAttachment: Decodable {
    public let shout: Shout?
    public let location: MessageLocation?
    public let profile: Profile?
    public let videos: [Video]?
    public let images: [String]?
    
    public init(shout: Shout?, location: MessageLocation?, profile: Profile?, videos: [Video]?, images: [String]?) {
        self.shout = shout
        self.location = location
        self.profile = profile
        self.videos = videos
        self.images = images
    }
        
    public func type() -> MessageAttachmentType? {
        if let s = shout { return .ShoutAttachment(shout: s) }
        if let l = location { return .LocationAttachment(location: l) }
        if let p = profile { return .ProfileAttachment(profile: p) }
        if let v = videos where v.count > 0 { return .VideoAttachment(video: v[0]) }
        if let i = images where i.count > 0 { return .ImageAttachment(path: i[0]) }
        return nil
    }
    
    public static func decode(j: JSON) -> Decoded<MessageAttachment> {
        return curry(MessageAttachment.init)
            <^> j <|? "shout"
            <*> j <|? "location"
            <*> j <|? "profile"
            <*> j <||? "videos"
            <*> j <||? "images"
    }
    
    public func encode() -> JSON {
        var encoded = [String:JSON]()
        encoded["shout"] = shout?.encode()
        encoded["location"] = location?.encode()
        encoded["videos"] = videos?.encode()
        encoded["images"] = images?.encode()
        encoded["profile"] = profile?.encode()
        return JSON.Object(encoded)
    }
}

extension MessageAttachment {
    
    public func imagePath() -> String? {
        guard let type = type() else { return nil }
        switch type {
        case .VideoAttachment(let video):
            return video.thumbnailPath
        case .ImageAttachment(let path):
            return path
        case .ShoutAttachment(let shout):
            return shout.thumbnailPath
        default:
            return nil
        }
    }
    
    public func videoPath() -> String? {
        return self.videos?.first?.path
    }
}

public struct MessageLocation: Decodable, Encodable {
    public let longitude: Double
    public let latitude: Double
    
    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    public static func decode(j: JSON) -> Decoded<MessageLocation> {
        return curry(MessageLocation.init)
            <^> j <| "longitude"
            <*> j <| "latitude"
    }
    
    public func encode() -> JSON {
        return JSON.Object(["longitude": longitude.encode(),
                            "latitude": latitude.encode()])
    }
    
    public func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}
