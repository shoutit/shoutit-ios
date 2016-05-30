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
import ContactsPicker

struct Contact {
    let firstName: String?
    let lastName: String?
    let name: String?
    let mobiles: [String]?
    let emails: [String]?
}

struct ContactsParams : Params {
    let contacts : [Contact]
    
    var params: [String : AnyObject] {
        return ["contacts" : self.contacts.encode().JSONObject()]
    }
}

extension Contact: Decodable {
    static func decode(j: JSON) -> Decoded<Contact> {
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
    func encode() -> JSON {
        return JSON.Object(["first_name": self.firstName.encode(),
            "last_name" : self.lastName.encode(),
            "name" : self.name.encode(),
            "mobiles" : self.mobiles.encode(),
            "emails" : self.emails.encode()])
    }
}

extension ContactProtocol {
    func toContact() -> Contact {
        
        var phoneNumbers : [String] = []
        
        var emails : [String] = []
        
        self.phoneNumbers?.each({ (label) in
            if let number = label.value as? String {
                phoneNumbers.append(number)
            }
        })
        
        self.emailAddresses?.each({ (label) in
            if let number = label.value as? String {
                emails.append(number)
            }
        })
        
        return Contact(firstName: self.firstName, lastName: self.lastName, name: self.fullName, mobiles: phoneNumbers, emails: emails)
    }
}