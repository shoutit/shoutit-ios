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
    case image(url: URL)
    case noContent(image: UIImage)
    case loading
    case error(error: Error)
    case movie(video: Video)
}

extension ShoutDetailShoutImageViewModel {
    
    func canShowPreview() -> Bool {
        switch self {
        case .image, .movie:
            return true
        default:
            return false
        }
    }
    
    func mwPhoto() -> MWPhoto? {
        switch self {
        case .image(let url):
            return MWPhoto(url: url.imageUrlByAppendingVaraitionComponent(.large))
        case .movie(let video):
            guard let url = video.path.toURL(), let thumbURL = video.thumbnailPath.toURL() else { return nil }
            return MWPhoto(videoURL: url, thumbnailURL: thumbURL.imageUrlByAppendingVaraitionComponent(.large))
        default:
            return nil
        }
    }
}
