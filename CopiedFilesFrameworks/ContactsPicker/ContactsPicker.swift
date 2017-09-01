//
//  MyAddressBook.swift
//  ContactsPicker
//
//  Created by Piotr on 23/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation

public protocol AddressBookProtocol {
    
    func requestAccessToAddressBook( _ completion: @escaping (Bool, Error?) -> Void )

    func retrieveAddressBookRecordsCount() throws -> Int

    func addContactToAddressBook(_ contact: ContactProtocol) throws -> ContactProtocol
    
    func updateContact(_ contact: ContactProtocol)
    
    func deleteAllContacts() throws
    
    func deleteContactWithIdentifier(_ identifier: String?) throws
    
    func queryBuilder() -> AddressBookQueryBuilder
    
    func findContactWithIdentifier(_ identifier: String?) -> ContactProtocol?
    
    func findContactsMatchingName(_ name: String) throws -> [ContactProtocol]
    
    func findAllContacts() throws -> [ContactProtocol]

    func commitChangesToAddressBook() throws
}

public protocol AddressBookFactory {
    func createAddressBook() throws -> AddressBookProtocol
}

open class APIVersionAddressBookFactory : AddressBookFactory {
    
    open func createAddressBook() throws -> AddressBookProtocol {

        if #available(iOS 9.0, *) {
            return CNAddressBookImpl()
        } else {
           return try ABAddressBookImpl()
        }
        
    }
}

open class AddressBook: AddressBookProtocol {
    public func requestAccessToAddressBook(_ completion: @escaping (Bool, Error?) -> Void) {
        internalAddressBook.requestAccessToAddressBook(completion)
    }

    fileprivate var internalAddressBook: AddressBookProtocol!
    
    public convenience init() throws {
        try self.init(factory: APIVersionAddressBookFactory())
    }
    
    public init(factory: AddressBookFactory) throws {
        internalAddressBook = try factory.createAddressBook()
    }
    
    open func retrieveAddressBookRecordsCount() throws -> Int {
        return try internalAddressBook.retrieveAddressBookRecordsCount()
    }
    
    open func addContactToAddressBook(_ contact: ContactProtocol) throws -> ContactProtocol {
        return try internalAddressBook.addContactToAddressBook(contact)
    }
    
    open func updateContact(_ contact: ContactProtocol) {
        internalAddressBook.updateContact(contact)
    }
    
    open func deleteContactWithIdentifier(_ identifier: String?) throws {
        try internalAddressBook.deleteContactWithIdentifier(identifier)
    }
    
    open func deleteAllContacts() throws {
        try internalAddressBook.deleteAllContacts()
    }
    
    open func commitChangesToAddressBook() throws {
        try internalAddressBook.commitChangesToAddressBook()
    }
    
    open func queryBuilder() -> AddressBookQueryBuilder {
        return internalAddressBook.queryBuilder()
    }
    
    open func findContactWithIdentifier(_ identifier: String?) -> ContactProtocol? {
        return internalAddressBook.findContactWithIdentifier(identifier)
    }
    
    open func findAllContacts() throws -> [ContactProtocol] {
        return try internalAddressBook.findAllContacts()
    }
    
    open func findContactsMatchingName(_ name: String) throws -> [ContactProtocol] {
        return try internalAddressBook.findContactsMatchingName(name)
    }
}
