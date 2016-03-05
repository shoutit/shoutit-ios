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

struct MediaAttachment {
    
    let type: PHAssetMediaType
    
    var image: UIImage?
    var originalData: NSData?
    
    var remoteURL: NSURL?
    var thumbRemoteURL: NSURL?
}

typealias MediaPickerError = ErrorType
extension MediaPickerError {
    
}

protocol MediaPicker : PhotosMenuControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var pickerSettings : MediaPickerSettings! { get set }

    func attachmentSelected(attachment: MediaAttachment)
    
}

extension MediaPicker {
    
}

extension PHAsset {
    func asMediaAttachment(image: UIImage? = nil) -> MediaAttachment {
        return MediaAttachment(type: self.mediaType, image: image, originalData: nil, remoteURL: nil, thumbRemoteURL: nil)
    }
}