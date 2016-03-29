//
//  AutocompletionTerm.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct AutocompletionTerm {
    let term: String
}

extension AutocompletionTerm: Decodable {
    
    static func decode(j: JSON) -> Decoded<AutocompletionTerm> {
        return curry(AutocompletionTerm.init)
            <^> j <| "term"
    }
}
