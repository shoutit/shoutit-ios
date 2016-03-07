//
//  MediaUploadingTask.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum MediaUploadingTaskStatus : Int {
    case Uploading
    case Uploaded
    case Error
}

class MediaUploadingTask: NSObject {
    var attachment : MediaAttachment!
    var progress : NSProgress?
    
    required init(attachment: MediaAttachment) {
        super.init()
        self.attachment = attachment
    }
}
