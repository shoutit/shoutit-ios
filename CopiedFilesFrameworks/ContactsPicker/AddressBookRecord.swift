//
//  AddressBookRecord.swift
//  ContactsPicker
//
//  Created by Piotr on 04/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation

open class AddressBookRecord: ContactProtocol {
    
    open var identifier: String? {
        get {
            return nil
        }
    }
    
    open var firstName: String?
    
    open var lastName: String?
    
    open var phoneNumbers: [AddressBookRecordLabel]?
    
    open var emailAddresses: [AddressBookRecordLabel]?
    
    open var organizationName: String?
    
    open var middleName: String?
    
    public init() {
        phoneNumbers = [AddressBookRecordLabel]()
        emailAddresses = [AddressBookRecordLabel]()
    }
    
    public convenience init(firstName: String, lastName: String) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
    }
    
}
