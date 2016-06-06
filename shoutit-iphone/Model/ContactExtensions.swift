//
//  ContactExtensions.swift
//  shoutit
//
//  Created by Piotr Bernad on 06/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ContactsPicker
import ShoutitKit

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