//
//  Report.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 13.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct Report {
    let text: String
    let object: Reportable
}

struct ReportObject : JSONEncodable {
    var id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
        })
    }
}

extension Report: JSONEncodable {
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(text, key: "text")
            try encoder.encode(ReportObject(object.id), key:object.reportTypeKey)
        })
    }
}
