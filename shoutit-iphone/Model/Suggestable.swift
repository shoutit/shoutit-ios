//
//  Suggestable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol Suggestable {
    var listenId: String {get}
    var suggestionTitle: String {get}
    var suggestionId: String {get} // user for api requests
    var thumbnailURL: NSURL? {get}
    var listenersCount: Int {get}
}

extension Profile: Suggestable {
    
    var listenId: String {
        return self.username
    }
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
    var listenId: String {
        return self.id
    }
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
    var listenersCount: Int {
        return 0
    }
}