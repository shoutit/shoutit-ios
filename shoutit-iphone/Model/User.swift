//
//  User.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

public protocol User: Encodable {
    
    var id: String {get}
    var type: UserType {get}
    var apiPath: String {get}
    var username: String {get}
    var isGuest: Bool {get}
    var dateJoinedEpoch: Int {get}
    var location: Address {get}
    var pushTokens: PushTokens? {get}
    
}

extension User {
    
    public func basicEncodedProfile() -> [String: AnyObject]! {

        return ["username": self.username.encode(), "id": self.id.encode()].encode().JSONObject() as! [String : AnyObject]
    }
}

// MARK: - User type

public enum UserType: String {
    case Page = "page"
    case User = "user"
}

extension UserType: Decodable {
    
    public static func decode(j: JSON) -> Decoded<UserType> {
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
    
    public func encode() -> JSON {
        return self.rawValue.encode()
    }
}

// MARK: - Gender

public enum Gender: String {
    case Male = "male"
    case Female = "female"
}

extension Gender: Decodable {
    
    public static func decode(j: JSON) -> Decoded<Gender> {
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
    
    public func encode() -> JSON {
        return self.rawValue.encode()
    }
}
