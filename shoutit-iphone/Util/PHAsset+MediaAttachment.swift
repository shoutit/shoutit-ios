//
//  PHAsset+MediaAttachment.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension PHAsset {
    func asMediaAttachment(image: UIImage? = nil) -> MediaAttachment {
        return MediaAttachment(type: self.mediaType, image: image, originalData: image?.dataRepresentation(), remoteURL: nil, thumbRemoteURL: nil, uid: MediaAttachment.generateUid(), videoDuration: nil)
    }
}
