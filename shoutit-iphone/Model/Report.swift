//
//  Report.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 13.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct Report {
    let text: String
    let object: Reportable
}

extension Report: Encodable {
    func encode() -> JSON {
        
        var json = [String: JSON]()
        
        json["text"] = self.text.encode()
        
        json["attached_object"] = self.object.attachedObjectJSON()
        
        return JSON.Object(json)
    }
}