//
//  LightError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct LightError: ShoutitError {
    public let userMessage: String
    
    public init(userMessage: String) {
        self.userMessage = userMessage
    }
}