//
//  Contact.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 30/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import JSONCodable

public struct Contact {
    public let firstName: String?
    public let lastName: String?
    public let name: String?
    public let mobiles: [String]?
    public let emails: [String]?
    
    public init(firstName: String?, lastName: String?, name: String?, mobiles: [String]?, emails: [String]?) {
        self.firstName = firstName
        self.lastName = lastName
        self.name = name
        self.mobiles = mobiles
        self.emails = emails
    }
}

public struct ContactsParams : Params, JSONEncodable {
    let contacts : [Contact]
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(contacts, key: "contacts")
        })
    }
    
    public init(contacts: [Contact]) {
        self.contacts = contacts
    }
}

extension Contact: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        firstName = try decoder.decode("first_name")
        lastName = try decoder.decode("last_name")
        name = try decoder.decode("name")
        mobiles = try decoder.decode("mobiles")
        emails = try decoder.decode("emails")
        
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(firstName, key: "first_name")
            try encoder.encode(lastName, key: "last_name")
            try encoder.encode(name, key: "name")
            try encoder.encode(mobiles, key: "mobiles")
            try encoder.encode(emails, key: "emails")
        })
    }
}
