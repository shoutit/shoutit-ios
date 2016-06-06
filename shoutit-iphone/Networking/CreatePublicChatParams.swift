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
        params["subject"] = subject
        params["icon"] = iconPath
        if let latitude = location.latitude, longitude = location.longitude {
            let locationParams: [String : AnyObject] = [
                "latitude" : latitude,
                "longitude" : longitude
            ]
            params["location"] = locationParams
        }
        return params
    }
}
