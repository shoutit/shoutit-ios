//
//  MediaPickerControllerProtocol.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 05/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Nemo
import MobileCoreServices

struct MediaPickerSettings {
    var thumbnailSize : CGSize = CGSize(width: 100, height: 100)
    var targetSize : CGSize = PHImageManagerMaximumSize
    var contentMode : PHImageContentMode = .AspectFill
    var videoLength : NSTimeInterval = 10.0
    var maximumItems : Int = 5
    var maximumVideos : Int = 1
}

struct MediaAttachment : Hashable, Equatable {
    
    static let maximumImageWidth : CGFloat = 1024.0
    
    let type: PHAssetMediaType
    
    var image: UIImage?
    var originalData: NSData?
    
    var remoteURL: NSURL?
    var thumbRemoteURL: NSURL?
    
    var uid: String!
    
    var videoDuration : Float?
    let provider = "shoutit_s3"
    
    func remoteFilename(user: User) -> String {
        if self.type == .Image {
            return "\(Int(NSDate().timeIntervalSince1970))_\(user.id).jpg"
        }
        
        return "\(Int(NSDate().timeIntervalSince1970))_\(user.id).mp4"
    }
    
    func thumbRemoteFilename(user: User) -> String {
        return "\(Int(NSDate().timeIntervalSince1970))_\(user.id)_thumbnail.jpg"
    }
    
    static func generateUid() -> String {
        return NSUUID().UUIDString
    }
    
    var hashValue: Int {
        get {
            return self.uid.hashValue
        }
    }

}

func ==(lhs: MediaAttachment, rhs: MediaAttachment) -> Bool {
    return lhs.uid == rhs.uid
}


protocol MediaPicker : PhotosMenuControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var pickerSettings : MediaPickerSettings! { get set }

    func attachmentSelected(attachment: MediaAttachment)
    
}

extension MediaAttachment {
    func asVideoObject() -> Video {
        return Video(path: self.remoteURL!.absoluteString, thumbnailPath:  self.thumbRemoteURL!.absoluteString, provider: self.provider, idOnProvider: (self.remoteURL?.lastPathComponent ?? ""), duration: Int(self.videoDuration ?? 0))
    }
}

extension UIImage {
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        if newWidth > image.size.width {
            return image
        }
        
        let scale = newWidth / image.size.height
        
        let newHeight = image.size.width * scale
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func dataRepresentation() -> NSData? {
        let resizedImage = UIImage.resizeImage(self, newWidth: MediaAttachment.maximumImageWidth)
        
        return UIImageJPEGRepresentation(resizedImage, 0.7)
    }
}

extension PHAsset {
    func asMediaAttachment(image: UIImage? = nil) -> MediaAttachment {
        return MediaAttachment(type: self.mediaType, image: image, originalData: image?.dataRepresentation(), remoteURL: nil, thumbRemoteURL: nil, uid: MediaAttachment.generateUid(), videoDuration: nil)
    }
}