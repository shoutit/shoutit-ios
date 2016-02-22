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

// MARK: - User type

enum UserType: String {
    case Profile = "Profile"
    case Page = "Page"
}

extension UserType: Decodable {
    
    static func decode(j: JSON) -> Decoded<UserType> {
        switch j {
        case .String(let string):
            if let userType = UserType(rawValue: string) {
                return pure(userType)
            }
            return .typeMismatch("UserType", actual: j)
        default:
            return .typeMismatch("String", actual: j)
        }
    }
}

extension UserType: Encodable {
    
    func encode() -> JSON {
        return self.rawValue.encode()
    }
}

// MARK: - Gender

enum Gender: String {
    case Male = "male"
    case Female = "female"
}

extension Gender: Decodable {
    
    static func decode(j: JSON) -> Decoded<Gender> {
        switch j {
        case .String(let string):
            if let gender = Gender(rawValue: string) {
                return pure(gender)
            }
            return .typeMismatch("Gender", actual: j)
        default:
            return .typeMismatch("String", actual: j)
        }
    }
}

extension Gender: Encodable {
    
    func encode() -> JSON {
        return self.rawValue.encode()
    }
}