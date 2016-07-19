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
    
    public func sh_setImageWithURL(url: NSURL?, placeholderImage: UIImage?, optionsInfo: KingfisherOptionsInfo?, completionHandler: CompletionHandler?) {
        if let url = url where url.absoluteString.utf16.count > 0 {
            if let variation = estimateAppropriateVariation() {
                kf_setImageWithURL(url.imageUrlByAppendingVaraitionComponent(variation), placeholderImage: placeholderImage, optionsInfo: optionsInfo, completionHandler: completionHandler)
            } else {
                kf_setImageWithURL(url.imageUrlByAppendingVaraitionComponent(.Large), placeholderImage: placeholderImage, optionsInfo: optionsInfo, completionHandler: completionHandler)
            }
        } else if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        } else {
            self.image = nil
        }
    }
    
    public func sh_setImageWithURL(url: NSURL?, placeholderImage: UIImage?) {
        if let url = url where url.absoluteString.utf16.count > 0 {
            if let variation = estimateAppropriateVariation() {
                kf_setImageWithURL(url.imageUrlByAppendingVaraitionComponent(variation), placeholderImage: placeholderImage)
            } else {
                kf_setImageWithURL(url.imageUrlByAppendingVaraitionComponent(.Large), placeholderImage: placeholderImage)
            }
        } else if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        } else {
            self.image = nil
        }
    }
    
    public func sh_cancelImageDownload() {
        kf_cancelDownloadTask()
    }
    
    private func estimateAppropriateVariation() -> ImageVariation? {
        let scale = UIScreen.mainScreen().scale
        let scaledWidth = floor(bounds.size.width * scale)
        let scaledHeight = floor(bounds.size.height * scale)
        
        for variation: ImageVariation in [.Small, .Medium, .Large] {
            if scaledWidth <= variation.size.width && scaledHeight <= variation.size.height {
                return variation
            }
        }
        
        return nil
    }
}
