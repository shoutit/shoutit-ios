//
//  Suggestable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public protocol Suggestable {
    var listenId: String {get}
    var suggestionTitle: String {get}
    var suggestionId: String {get} // user for api requests
    var thumbnailURL: NSURL? {get}
    var listenersCount: Int {get}
}

extension Profile: Suggestable {
    
    public var listenId: String {
        return self.username
    }
    public var suggestionTitle: String {
        return self.name
    }
    public var suggestionId: String {
        return self.username
    }
    public var thumbnailURL: NSURL? {
        return (self.imagePath != nil) ? NSURL(string: self.imagePath!) : nil
    }
}