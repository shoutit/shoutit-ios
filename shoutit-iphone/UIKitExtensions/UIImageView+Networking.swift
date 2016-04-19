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
    }
    
    public func sh_setImageWithURL(url: NSURL?, placeholderImage: UIImage?, variation: ImageVariation?, optionsInfo: KingfisherOptionsInfo?, completionHandler: CompletionHandler?) {
        if let url = url {
            if let variation = variation {
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
    
    public func sh_setImageWithURL(url: NSURL?, placeholderImage: UIImage?, variation: ImageVariation?) {
        if let url = url {
            if let variation = variation {
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
    
    private func imageUrlByAppendingVaraitionComponent(varation: ImageVariation, toURL url: NSURL) -> NSURL {
        guard let fileExtension = url.pathExtension else { assertionFailure(); return url; }
        guard let originalPath = url.URLByDeletingPathExtension?.absoluteString else { assertionFailure(); return url; }
        guard let noExtensionURL = NSURL(string: originalPath + varation.pathComponent) else { assertionFailure(); return url; }
        return noExtensionURL.URLByAppendingPathExtension(fileExtension)
    }
}
