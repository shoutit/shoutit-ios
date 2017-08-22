//
//  CreatePublicChatParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 16.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct CreatePublicChatParams: Params {
    public let subject: String
    public let iconPath: String?
    public let location: Address
    
    public var params: [String : AnyObject] {
        var params: [String : AnyObject] = [:]
        params["subject"] = subject as AnyObject
        params["icon"] = iconPath as AnyObject
        if let latitude = location.latitude, let longitude = location.longitude {
            let locationParams: [String : AnyObject] = [
                "latitude" : latitude as AnyObject,
                "longitude" : longitude as AnyObject
            ]
            params["location"] = locationParams as AnyObject
        }
        return params
    }
    
    public init(subject: String, iconPath: String?, location: Address) {
        self.subject = subject
        self.iconPath = iconPath
        self.location = location
    }
}
