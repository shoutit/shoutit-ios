//
//  ConversationUpdateParams.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

public struct ConversationUpdateParams: Params {
    public let subject : String?
    public let icon: String?
    
    public var params: [String : AnyObject] {
        var params: [String : AnyObject] = [:]
        params["subject"] = subject
        params["icon"] = icon
        return params
    }
    
    public init(subject: String?, icon: String?) {
        self.subject = subject
        self.icon = icon
    }
}
