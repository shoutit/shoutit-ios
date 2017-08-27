//
//  CNAddressBookImpl.swift
//  ContactsPicker
//
//  Created by Piotr on 24/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import Contacts

@available(iOS 9.0, *)
internal class CNAddressBookImpl: AddressBookProtocol {
    func requestAccessToAddressBook(_ completion: (Bool, NSError?) -> Void) {
        contactStore.requestAccess(for: CNEntityType.contacts) { (access, err) -> Void in
            completion(access, err as! NSError)
        }
    }

    
    fileprivate var contactStore: CNContactStore!
    fileprivate var saveRequest: CNSaveRequest = CNSaveRequest()
    fileprivate let defaultKeysToFetch = [
        CNContactGivenNameKey,
        CNContactMiddleNameKey,
        CNContactFamilyNameKey,
        CNContactEmailAddressesKey,
        CNContactPhoneNumbersKey,
        CNContactIdentifierKey
    ]
    
    internal var allContactsPredicate: NSPredicate {
        get {
            let containerId = contactStore.defaultContainerIdentifier()
            let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
            return predicate
        }
    }
    
    internal init() {
        contactStore = CNContactStore()
    }
    
    func retrieveAddressBookRecordsCount() throws -> Int {
        let containerId = contactStore.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        return try contactStore.unifiedContacts(matching: predicate, keysToFetch: []).count
    }
    
    func addContactToAddressBook(_ contact: ContactProtocol) throws -> ContactProtocol {
        let cnContact = CNAdapter.convertContactValuesToCNContact(contact)
        saveRequest.add(cnContact, toContainerWithIdentifier: nil)
        return CNContactRecord(cnContact: cnContact)
    }
    
    func updateContact(_ contact: ContactProtocol) {
        guard let record = contact as? CNContactRecord else {
            return
        }
        
        saveRequest.update(record.wrappedContact)
    }
    
    func findContactWithIdentifier(_ identifier: String?) -> ContactProtocol? {
        guard let id = identifier else {
            return nil
        }

        do {
            let contact = try contactStore.unifiedContact(withIdentifier: id, keysToFetch: defaultKeysToFetch as [CNKeyDescriptor])
            return CNContactRecord(cnContact: contact.mutableCopy() as! CNMutableContact)
        } catch {
            return nil
        }
    }
    
    func queryBuilder() -> AddressBookQueryBuilder {
        return CNAddressBookQueryBuilder(addressBook: self)
    }
    
    func findAllContacts() throws -> [ContactProtocol] {
        return try fetchContactsUsingPredicate(allContactsPredicate)
    }
    
    func findContactsMatchingName(_ name: String) throws -> [ContactProtocol] {
        let predicate = CNContact.predicateForContacts(matchingName: name)
        return try fetchContactsUsingPredicate(predicate)
    }
    
    func fetchContactsUsingPredicate(_ predicate: NSPredicate) throws -> [ContactProtocol] {
        return try fetchContactsUsingPredicate(predicate, keys: defaultKeysToFetch)
    }
    
    func fetchContactsUsingPredicate(_ predicate: NSPredicate, keys: [String]) throws -> [ContactProtocol] {
        let cnContacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
        return CNAdapter.convertCNContactsToContactRecords(cnContacts)
    }
    
    func deleteContactWithIdentifier(_ identifier: String?) throws {
        guard let id = identifier else {
            return
        }

        do {
            let contact = try contactStore.unifiedContact(withIdentifier: id, keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor])
            saveRequest.delete(contact.mutableCopy() as! CNMutableContact)
        } catch let e{
            throw e
        }
    }
    
    func deleteAllContacts() throws {
        let containerId = contactStore.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        let keys = [CNContactIdentifierKey]
        do {
            let allContacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
            for contact in allContacts {
                saveRequest.delete(contact.mutableCopy() as! CNMutableContact)
            }
        } catch let e {
            throw e
        }
        
    }
    
    func commitChangesToAddressBook() throws {
        try contactStore.execute(saveRequest)
        saveRequest = CNSaveRequest()
    }
}


