//
//  PromoteShoutParams.swift
//  shoutit
//
//  Created by Piotr Bernad on 17/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct PromoteShoutParams: Params {
    
    public let shout: Shout
    public let option: PromotionOption
    
    public init(shout: Shout, option: PromotionOption) {
        self.shout = shout
        self.option = option
    }
    
    public var params: [String : AnyObject] {
        return [
            "option" : ["id":self.option.id] as AnyObject
            ]
    }
}
