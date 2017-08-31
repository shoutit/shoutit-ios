//
//  MediaPickerControllerProtocol.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 05/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import MobileCoreServices
import ShoutitKit

protocol MediaPicker : PhotosMenuControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    var pickerSettings : MediaPickerSettings { get set }
    func attachmentSelected(_ attachment: MediaAttachment)
}

struct MediaPickerSettings {
    var thumbnailSize : CGSize = CGSize(width: 100, height: 100)
    var targetSize : CGSize = PHImageManagerMaximumSize
    var contentMode : PHImageContentMode = .aspectFill
    var videoLength : TimeInterval = 10.0
    var maximumItems : Int = 5
    var maximumVideos : Int = 1
    var allowsVideos: Bool = true
}

struct MediaAttachment : Hashable, Equatable {
    
    static let maximumImageWidth : CGFloat = 1024.0
    let provider = "shoutit_s3"
    
    let type: PHAssetMediaType
    
    var uid: String!
    
    var remoteURL: URL?
    var thumbRemoteURL: URL?
    
    var image: UIImage?
    var videoDuration : Float?
    var originalData: Data?
    
    func remoteFilename(_ user: User) -> String {
        
        if self.type == .image {
            return "\(Int(Date().timeIntervalSince1970))_\(arc4random()%100)_\(user.id).jpg"
        }
        
        return "\(Int(Date().timeIntervalSince1970))_\(arc4random()%100)_\(user.id).mp4"
    }
    
    func thumbRemoteFilename(_ user: User) -> String {
        return "\(Int(Date().timeIntervalSince1970))_\(arc4random()%100)_\(user.id)_thumbnail.jpg"
    }
    
    static func generateUid() -> String {
        return UUID().uuidString
    }
    
    var hashValue: Int {
        get {
            return self.uid.hashValue
        }
    }
    
    func mediaAttachmentWithExchangedImage(_ nimage: UIImage, data: Data) -> MediaAttachment {
        return MediaAttachment(type: self.type, uid: self.uid, remoteURL: self.remoteURL, thumbRemoteURL: self.thumbRemoteURL, image: nimage, videoDuration: self.videoDuration, originalData: data)
    }

}

func ==(lhs: MediaAttachment, rhs: MediaAttachment) -> Bool {
    return lhs.uid == rhs.uid
}

extension MediaAttachment {
    
    func asMessageAttachment() -> MessageAttachment {
        if self.type == .image {
            return MessageAttachment(shout: nil, location: nil, profile: nil, videos: nil, images: [(self.remoteURL?.absoluteString)!])
        }
        
        if self.type == .video {
            return MessageAttachment(shout: nil, location: nil, profile: nil, videos: [self.asVideoObject()!], images: nil)
        }
        
        fatalError("Unexpected attachment type")
    }
}

extension MediaAttachment {
    
    func asVideoObject() -> Video? {
        guard let remoteURL = self.remoteURL else { return nil }
        return Video(path: remoteURL.absoluteString,
                     thumbnailPath: (self.thumbRemoteURL?.absoluteString ?? ""),
                     provider: self.provider,
                     idOnProvider: (remoteURL.lastPathComponent ?? ""),
                     duration: Int(self.videoDuration ?? 0))
    }
}
