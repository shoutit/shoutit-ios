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

enum MessageAttachmentType {
    case Shout
    case Location
    case Video
    case Image
}

struct MessageAttachment: Decodable {
    let shout: Shout?
    let location: MessageLocation?
    let videos: [Video]?
    let images: [String]?
        
    func type() -> MessageAttachmentType {
        if let _ = shout {
            return .Shout
        }
        if let _ = location {
            return .Location
        }
        if let videos = videos {
            if videos.count > 0 {
                return .Video
            }
        }
        
        return .Image
    }
    
    static func decode(j: JSON) -> Decoded<MessageAttachment> {
        return curry(MessageAttachment.init)
            <^> j <|? "shout"
            <*> j <|? "location"
            <*> j <||? "videos"
            <*> j <||? "images"
    }
    
    func encode() -> JSON {
        var encoded = [String:JSON]()
       
        if let shout = shout {
            encoded["shout"] = shout.encode()
        }
        
        if let location = location {
            encoded["location"] = location.encode()
        }
        
        if let videos = videos {
            encoded["videos"] = videos.encode()
        }
        
        if let images = images {
            encoded["images"] = images.encode()
        }
        
        return JSON.Object(encoded)
    }
}

extension MessageAttachment {
    func imagePath() -> String? {
        if self.type() == .Video {
            return self.videos?.first?.thumbnailPath
        }
        
        if self.type() == .Shout {
            return self.shout?.thumbnailPath
        }
        
        return self.images?.first
    }
    
    func videoPath() -> String? {
        return self.videos?.first?.path
    }
}

struct MessageLocation: Decodable, Encodable {
    let longitude: Double
    let latitude: Double
    
    static func decode(j: JSON) -> Decoded<MessageLocation> {
        return curry(MessageLocation.init)
            <^> j <| "longitude"
            <*> j <| "latitude"
    }
    
    func encode() -> JSON {
        return JSON.Object(["longitude": longitude.encode(),
                            "latitude": latitude.encode()])
    }
    
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}
