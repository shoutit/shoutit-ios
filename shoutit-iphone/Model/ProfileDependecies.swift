//
//  ProfileDependecies.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

enum UserType: String {
    case Profile = "Profile"
    case Page = "Page"
}

extension UserType: Decodable {
    
    static func decode(j: JSON) -> Decoded<UserType> {
        switch j {
        case .String(let string):
            switch string {
            case UserType.Profile.rawValue:
                return pure(.Profile)
            case UserType.Page.rawValue:
                return pure(.Page)
            default:
                return .typeMismatch("User type", actual: j)
            }
        default:
            return .typeMismatch("String", actual: j)
        }
    }
}

extension UserType: Encodable {
    
    func encode() -> JSON {
        return self.rawValue
    }
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