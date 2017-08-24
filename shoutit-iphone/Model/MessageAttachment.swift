//
//  MessageAttachment.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import CoreLocation
import JSONCodable

public enum MessageAttachmentType {
    case shoutAttachment(shout: Shout)
    case locationAttachment(location: MessageLocation)
    case imageAttachment(path: String)
    case videoAttachment(video: Video)
    case profileAttachment(profile: Profile)
}

public struct MessageAttachment {
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
}

extension MessageAttachment: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        shout = try decoder.decode("shout")
        location = try decoder.decode("location")
        videos = try decoder.decode("videos")
        images = try decoder.decode("images")
        profile = try decoder.decode("profile")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(shout, key: "shout")
            try encoder.encode(location, key: "location")
            try encoder.encode(videos, key: "videos")
            try encoder.encode(images, key: "images")
            try encoder.encode(profile, key: "profile")
        })
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

public struct MessageLocation {
    public let longitude: Double
    public let latitude: Double
    
    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }

    
    public func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}

extension MessageLocation: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        longitude = try decoder.decode("longitude")
        latitude = try decoder.decode("latitude")

    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(longitude, key: "longitude")
            try encoder.encode(latitude, key: "latitude")

        })
    }
}
