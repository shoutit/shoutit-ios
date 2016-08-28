//
//  SoldParams.swift
//  shoutit
//
//  Created by Piotr Bernad on 23.08.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct SoldParams: Params {
    public let sold: Bool
    
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["is_sold"] = sold
        
        return p
    }
    
    public init(sold: Bool) {
        self.sold = sold
    }
}
