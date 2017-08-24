//
//  ProfileIdParams.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 24.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct ProfileIdParams: Params {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
    
    public var params: [String : AnyObject] {
        return ["profile" : ["id" : id] as AnyObject]
    }
}
