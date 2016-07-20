//
//  ShoutDetailShoutImageViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum ShoutDetailShoutImageViewModel {
    case Image(url: NSURL)
    case NoContent(image: UIImage)
    case Loading
    case Error(error: ErrorType)
    case Movie(video: Video)
}

extension ShoutDetailShoutImageViewModel {
    
    func canShowPreview() -> Bool {
        switch self {
        case .Image, .Movie:
            return true
        default:
            return false
        }
    }
    
    func mwPhoto() -> MWPhoto? {
        switch self {
        case .Image(let url):
            return MWPhoto(URL: url.imageUrlByAppendingVaraitionComponent(.Large))
        case .Movie(let video):
            guard let url = video.path.toURL(), thumbURL = video.thumbnailPath.toURL() else { return nil }
            return MWPhoto(videoURL: url, thumbnailURL: thumbURL.imageUrlByAppendingVaraitionComponent(.Large))
        default:
            return nil
        }
    }
}