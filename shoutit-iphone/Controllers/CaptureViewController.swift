//
//  CaptureViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 08.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Nemo
import MobileCoreServices

class CaptureViewController: PhotosMenuController {

    var allowsVideos: Bool = true
    
    override var mediaTypesForImagePicker: [String] {
        get {
            var types = [kUTTypeImage as String]
            if allowsVideos {
                types += [kUTTypeMovie as String]
            }
            return types
        }
        set {
            
        }
    }
}
