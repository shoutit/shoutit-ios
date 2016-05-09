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
    case ShoutAttachment(shout: Shout)
    case LocationAttachment(location: MessageLocation)
    case ImageAttachment(path: String)
    case VideoAttachment(video: Video)
    case ProfileAttachment(profile: Profile)
}

struct MessageAttachment: Decodable {
    let shout: Shout?
    let location: MessageLocation?
    let profile: Profile?
    let videos: [Video]?
    let images: [String]?
        
    func type() -> MessageAttachmentType {
        if let s = shout { return .ShoutAttachment(shout: s) }
        if let l = location { return .LocationAttachment(location: l) }
        if let p = profile { return .ProfileAttachment(profile: p) }
        if let v = videos where v.count > 0 { return .VideoAttachment(video: v[0]) }
        if let i = images where i.count > 0 { return .ImageAttachment(path: i[0]) }
        fatalError("Enexpected attachment object")
    }
    
    static func decode(j: JSON) -> Decoded<MessageAttachment> {
        return curry(MessageAttachment.init)
            <^> j <|? "shout"
            <*> j <|? "location"
            <*> j <|? "profile"
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
        switch type() {
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
