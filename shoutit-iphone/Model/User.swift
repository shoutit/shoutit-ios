//
//  User.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public protocol User: JSONEncodable {
    
    var id: String {get}
    var type: UserType {get}
    var apiPath: String {get}
    var username: String {get}
    var isGuest: Bool {get}
    var dateJoinedEpoch: Int {get}
    var location: Address {get}
    var pushTokens: PushTokens? {get}
    var name: String { get }
}

fileprivate struct BasicProfile: JSONEncodable {
    let username: String
    let id: String
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            
            try encoder.encode(id, key: "id")
            try encoder.encode(username, key: "username")
        })
    }
}

extension User {
    public func basicEncodedProfile() -> [String: AnyObject]! {
        return try! BasicProfile(username: self.name, id: id).toJSON() as! [String: AnyObject]
    }
}

// MARK: - User type

public enum UserType: String {
    case Page = "page"
    case User = "user"
}

// MARK: - Gender

public enum Gender: String {
    case Male = "male"
    case Female = "female"
    case Other = "other"
}
