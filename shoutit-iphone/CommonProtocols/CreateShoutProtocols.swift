//
//  CreateShoutProtocols.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ShoutImagesController {
    func selectedImages() -> [UIImage]
}

protocol ShoutCreateFormController {
    func shoutParams() -> [String:String]
}
