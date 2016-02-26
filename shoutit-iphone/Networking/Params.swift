//
//  Params.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol Params {
    var params: [String : AnyObject] {get}
}

struct NopParams: Params {
    
    init?() {
        return nil
    }
    
    var params: [String : AnyObject] {
        return [:]
    }
}
