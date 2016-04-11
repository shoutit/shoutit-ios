//
//  ShoutDetailShoutImageViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import MWPhotoBrowser

enum ShoutDetailShoutImageViewModel {
    case Image(url: NSURL)
    case NoContent(message: String)
    case Loading
    case Error(error: ErrorType)
    case Movie(video: Video)
}

extension ShoutDetailShoutImageViewModel {
    func canShowPreview() -> Bool {
        if case .Image = self {
            return true
        }
        
        if case .Movie = self {
            return true
        }
        
        return false
    }
    
    func mwPhoto() -> MWPhoto? {
        if case .Image(let path) = self {
            return MWPhoto(URL: path)
        }
        
        if case .Movie(let video) = self {
            guard let url = NSURL(string: video.path) else {
                return nil
            }
            
            return MWPhoto(videoURL: url)
        }
        
        return nil
    }
}