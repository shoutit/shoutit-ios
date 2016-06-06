//
//  Contact.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 30/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Argo
import Curry
import Ogra

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

public struct ContactsParams : Params {
    let contacts : [Contact]
    
    public var params: [String : AnyObject] {
        return ["contacts" : self.contacts.encode().JSONObject()]
    }
    
    public init(contacts: [Contact]) {
        self.contacts = contacts
    }
}

extension Contact: Decodable {
    public static func decode(j: JSON) -> Decoded<Contact> {
        let a = curry(Contact.init)
            <^> j <|? "first_name"
            <*> j <|? "last_name"
            <*> j <|? "name"
        
        
        let b = a
            <*> j <||? "mobiles"
            <*> j <||? "emails"
        
        return b
    }
}

extension Contact: Encodable {
    public func encode() -> JSON {
        return JSON.Object(["first_name": self.firstName.encode(),
            "last_name" : self.lastName.encode(),
            "name" : self.name.encode(),
            "mobiles" : self.mobiles.encode(),
            "emails" : self.emails.encode()])
    }
}

