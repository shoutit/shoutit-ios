//
//  CreatePublicChatViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 13.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class CreatePublicChatViewModel {
    
    // upload
    private(set) var imageUploadTask: MediaUploadingTask?
    lazy var mediaUploader: MediaUploader = {
        return MediaUploader(bucket: .TagImage)
    }()
    
    init() {
        
    }
    
    func uploadImageAttachment(attachment: MediaAttachment) -> MediaUploadingTask {
        let task = mediaUploader.uploadAttachment(attachment)
        imageUploadTask = task
        return task
    }
}
