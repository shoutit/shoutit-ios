//
//  ABAddressBookQueryBuilder.swift
//  ContactsPicker
//
//  Created by Piotr on 07/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import AddressBook

internal class ABAddressBookQueryBuilder: InternalAddressBookQueryBuilder<ABAddressBookImpl> {
    
    let addressBookPropertiesToABProperties: [AddressBookRecordProperty: ABPropertyID] = [
        AddressBookRecordProperty.firstName : kABPersonFirstNameProperty,
        AddressBookRecordProperty.middleName : kABPersonMiddleNameProperty,
        AddressBookRecordProperty.lastName : kABPersonLastNameProperty,
        AddressBookRecordProperty.emailAddresses : kABPersonEmailProperty,
        AddressBookRecordProperty.organizationName : kABPersonOrganizationProperty,
        AddressBookRecordProperty.phoneNumbers : kABPersonPhoneProperty
    ]
    
    internal override init(addressBook: ABAddressBookImpl) {
        super.init(addressBook: addressBook)
    }
    
    override func queryImpl() throws -> [ContactProtocol] {
        let abRecords = addressBook.findAllABRecords()
        return abRecords.map({ abRecord in
            removePropertiesFromRecord(abRecord)
            return ABContactRecord(abRecord: abRecord)
        })
    }
    
    func removePropertiesFromRecord(_ record: ABRecord) {
        let keysWhichShouldBeIgnored = Set(AddressBookRecordProperty.allValues).subtracting(keysToFetch)
        for key in keysWhichShouldBeIgnored {
            if let abKey = addressBookPropertiesToABProperties[key] {
                ABRecordRemoveValue(record, abKey, nil)
            }
        }
    }
}

