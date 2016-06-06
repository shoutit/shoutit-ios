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
    let firstName: String?
    let lastName: String?
    let name: String?
    let mobiles: [String]?
    let emails: [String]?
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

