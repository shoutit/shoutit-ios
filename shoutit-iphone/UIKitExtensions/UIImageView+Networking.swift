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
    
    public func sh_setImageWithURL(_ url: URL?, placeholderImage: UIImage?, optionsInfo: KingfisherOptionsInfo?, completionHandler: CompletionHandler?) {
        if let url = url, url.absoluteString.utf16.count > 0 {
            if let variation = estimateAppropriateVariation() {
                kf.setImage(with: url.imageUrlByAppendingVaraitionComponent(variation), placeholder: placeholderImage, options: optionsInfo, completionHandler: completionHandler)
            } else {
                kf.setImage(with: url.imageUrlByAppendingVaraitionComponent(.large), placeholder: placeholderImage, options: optionsInfo, completionHandler: completionHandler)
            }
        } else if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        } else {
            self.image = nil
        }
    }
    
    public func sh_setImageWithURL(_ url: URL?, placeholderImage: UIImage?) {
        if let url = url, url.absoluteString.utf16.count > 0 {
            if let variation = estimateAppropriateVariation() {
                kf.setImage(with: url.imageUrlByAppendingVaraitionComponent(variation), placeholder: placeholderImage)
            } else {
                kf.setImage(with: url.imageUrlByAppendingVaraitionComponent(.large), placeholder: placeholderImage)
            }
        } else if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        } else {
            self.image = nil
        }
    }
    
    public func sh_cancelImageDownload() {
        kf.cancelDownloadTask()
    }
    
    fileprivate func estimateAppropriateVariation() -> ImageVariation? {
        let scale = UIScreen.main.scale
        let scaledWidth = floor(bounds.size.width * scale)
        let scaledHeight = floor(bounds.size.height * scale)
        
        for variation: ImageVariation in [.small, .medium, .large] {
            if scaledWidth <= variation.size.width && scaledHeight <= variation.size.height {
                return variation
            }
        }
        
        return nil
    }
}
