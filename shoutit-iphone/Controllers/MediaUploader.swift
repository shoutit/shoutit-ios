//
//  MediaUploader.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class MediaUploader: AnyObject {
    var tasks : [MediaUploadingTask]!
    
    init() {
        tasks = []
    }
}
