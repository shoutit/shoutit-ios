//
//  AutocompletionTerm.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct AutocompletionTerm {
    public let term: String
    
    public init(term: String) {
        self.term = term
    }
}

extension AutocompletionTerm: Decodable {
    
    public static func decode(j: JSON) -> Decoded<AutocompletionTerm> {
        return curry(AutocompletionTerm.init)
            <^> j <| "term"
    }
}
