//
//  AutocompletionTerm.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct AutocompletionTerm {
    public let term: String
    
    public init(term: String) {
        self.term = term
    }
}

extension AutocompletionTerm: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        term = try decoder.decode("term")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(term, key: "term")
        })
    }
}
