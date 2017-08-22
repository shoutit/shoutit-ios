//
//  MessageAttachment.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra
import CoreLocation

public enum MessageAttachmentType {
    case shoutAttachment(shout: Shout)
    case locationAttachment(location: MessageLocation)
    case imageAttachment(path: String)
    case videoAttachment(video: Video)
    case profileAttachment(profile: Profile)
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
        if let s = shout { return .shoutAttachment(shout: s) }
        if let l = location { return .locationAttachment(location: l) }
        if let p = profile { return .profileAttachment(profile: p) }
        if let v = videos, v.count > 0 { return .videoAttachment(video: v[0]) }
        if let i = images, i.count > 0 { return .imageAttachment(path: i[0]) }
        return nil
    }
    
    public static func decode(_ j: JSON) -> Decoded<MessageAttachment> {
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
        return JSON.object(encoded)
    }
}

extension MessageAttachment {
    
    public func imagePath() -> String? {
        guard let type = type() else { return nil }
        switch type {
        case .videoAttachment(let video):
            return video.thumbnailPath
        case .imageAttachment(let path):
            return path
        case .shoutAttachment(let shout):
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
    
    public static func decode(_ j: JSON) -> Decoded<MessageLocation> {
        return curry(MessageLocation.init)
            <^> j <| "longitude"
            <*> j <| "latitude"
    }
    
    public func encode() -> JSON {
        return JSON.object(["longitude": longitude.encode(),
                            "latitude": latitude.encode()])
    }
    
    public func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}
