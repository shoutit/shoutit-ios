//
//  ConversationMemberParams.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

struct ConversationMemberParams: Params {
    let profileId : String
    
    var params: [String : AnyObject] {
        return ["profile": ["id": profileId]]
    }
}
