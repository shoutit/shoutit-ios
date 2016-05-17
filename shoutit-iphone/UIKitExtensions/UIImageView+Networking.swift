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
    
    public enum ImageVariation {
        case Small
        case Medium
        case Large
        
        var pathComponent: String {
            switch self {
            case .Small: return "_small"
            case .Medium: return "_medium"
            case .Large: return "_large"
            }
        }
        
        var size: CGSize {
            switch self {
            case .Small: return CGSize(width: 240, height: 240)
            case .Medium: return CGSize(width: 480, height: 480)
            case .Large: return CGSize(width: 720, height: 720)
            }
        }
    }
    
    public func sh_setImageWithURL(url: NSURL?, placeholderImage: UIImage?, optionsInfo: KingfisherOptionsInfo?, completionHandler: CompletionHandler?) {
        if let url = url {
            if let variation = estimateAppropriateVariation() {
                kf_setImageWithURL(imageUrlByAppendingVaraitionComponent(variation, toURL: url), placeholderImage: placeholderImage, optionsInfo: optionsInfo, completionHandler: completionHandler)
            } else {
                kf_setImageWithURL(url, placeholderImage: placeholderImage, optionsInfo: optionsInfo, completionHandler: completionHandler)
            }
        } else if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        } else {
            self.image = nil
        }
    }
    
    public func sh_setImageWithURL(url: NSURL?, placeholderImage: UIImage?) {
        if let url = url {
            if let variation = estimateAppropriateVariation() {
                kf_setImageWithURL(imageUrlByAppendingVaraitionComponent(variation, toURL: url), placeholderImage: placeholderImage)
            } else {
                kf_setImageWithURL(url, placeholderImage: placeholderImage)
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
    
    private func imageUrlByAppendingVaraitionComponent(varation: ImageVariation, toURL url: NSURL) -> NSURL {
        guard let fileExtension = url.pathExtension else { assertionFailure(); return url; }
        guard let originalPath = url.URLByDeletingPathExtension?.absoluteString else { assertionFailure(); return url; }
        guard let noExtensionURL = NSURL(string: originalPath + varation.pathComponent) else { assertionFailure(); return url; }
        return noExtensionURL.URLByAppendingPathExtension(fileExtension)
    }
}
