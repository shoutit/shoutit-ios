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
    
    let type: PHAssetMediaType
    
    var image: UIImage?
    var originalData: NSData?
    
    var remoteURL: NSURL?
    var thumbRemoteURL: NSURL?
    
    var uid: String!
    
    func remoteFilename(user: User) -> String {
        return "\(Int(NSDate().timeIntervalSince1970))_\(user.id)"
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

extension UIImage {
    func dataRepresentation() -> NSData? {
        return UIImageJPEGRepresentation(self, 0.7)
    }
}

extension PHAsset {
    func asMediaAttachment(image: UIImage? = nil) -> MediaAttachment {
        return MediaAttachment(type: self.mediaType, image: image, originalData: image?.dataRepresentation(), remoteURL: nil, thumbRemoteURL: nil, uid: MediaAttachment.generateUid())
    }
}