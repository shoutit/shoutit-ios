//
//  StringExtensions.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension String {
    
    func toURL() -> NSURL? {
        return NSURL(string: self)
    }
}
