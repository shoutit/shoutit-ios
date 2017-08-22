//
//  PHAsset+MediaAttachment.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension PHAsset {
    func asMediaAttachment(_ image: UIImage? = nil) -> MediaAttachment {
        return MediaAttachment(
            type: mediaType,
            uid: MediaAttachment.generateUid(),
            remoteURL: nil,
            thumbRemoteURL: nil,
            image: image,
            videoDuration: nil,
            originalData: image?.dataRepresentation()
        )
    }
}
