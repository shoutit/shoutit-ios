//
//  ConversationMemberParams.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

public struct ConversationMemberParams: Params {
    public let profileId : String
    
    public var params: [String : AnyObject] {
        return ["profile": ["id": profileId]]
    }
    
    public init(profileId: String) {
        self.profileId = profileId
    }
}
