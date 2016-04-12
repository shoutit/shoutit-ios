//
//  UIImageView+Networking.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func sh_setImageWithURL(url: NSURL?, placeholderImage: UIImage?, optionsInfo: KingfisherOptionsInfo?, completionHandler: CompletionHandler?) {
        if let url = url {
            kf_setImageWithURL(url, placeholderImage: placeholderImage, optionsInfo: optionsInfo, completionHandler: completionHandler)
        } else if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        } else {
            self.image = nil
        }
    }
    
    public func sh_setImageWithURL(url: NSURL?, placeholderImage: UIImage?) {
        if let url = url {
            kf_setImageWithURL(url, placeholderImage: placeholderImage)
        } else if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        } else {
            self.image = nil
        }
    }
}
