//
//  ArgoJsonParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

extension Argo.JSON: Params {
    
    public var params: [Swift.String : AnyObject] {
        guard let json = self.JSONObject() as? [Swift.String : AnyObject] else {
            assertionFailure()
            return [:]
        }
        return json
    }
}