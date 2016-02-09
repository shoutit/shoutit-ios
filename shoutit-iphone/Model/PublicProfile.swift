//
//  PublicProfile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum UserType: String {
    case Profile = "Profile"
    case Page = "Page"
}

enum Gender: String {
    
    init?(string: String?) {
        if let string = string {
            self.init(rawValue: string)!
        } else {
            self.init(rawValue: "unknown")
        }
    }
    
    case Unknown = "unknown"
    case Male = "male"
    case Female = "female"
}