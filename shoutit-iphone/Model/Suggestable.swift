//
//  Suggestable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol Suggestable {
    var suggestionTitle: String {get}
    var suggestionId: String {get} // user for api requests
    var thumbnailURL: NSURL? {get}
    var listenersCount: Int {get}
}

extension Suggestable {
    var listenersCount: Int {
        return 5000
    }
}

extension Profile: Suggestable {
    
    var suggestionTitle: String {
        return self.name
    }
    var suggestionId: String {
        return self.username
    }
    var thumbnailURL: NSURL? {
        return (self.imagePath != nil) ? NSURL(string: self.imagePath!) : nil
    }
}

extension Tag: Suggestable {
    var suggestionTitle: String {
        return self.name
    }
    var suggestionId: String {
        return self.name
    }
    var thumbnailURL: NSURL? {
        guard let path = self.imagePath else {
            return nil
        }
        return NSURL(string: path)
    }
}