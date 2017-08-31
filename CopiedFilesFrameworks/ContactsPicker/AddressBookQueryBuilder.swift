//
//  AddressBookQueryBuilder.swift
//  ContactsPicker
//
//  Created by Piotr on 07/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation

public typealias ContactPredicate = (_ contat: ContactProtocol) -> (Bool)
public typealias ContactResults = (_ results: [ContactProtocol]?, _ error: Error?) -> ()

public enum AddressBookRecordProperty {
    case identifier
    case firstName
    case middleName
    case lastName
    case phoneNumbers
    case emailAddresses
    case organizationName
    
    static let allValues = [
        AddressBookRecordProperty.identifier,
        AddressBookRecordProperty.firstName,
        AddressBookRecordProperty.middleName,
        AddressBookRecordProperty.lastName,
        AddressBookRecordProperty.phoneNumbers,
        AddressBookRecordProperty.emailAddresses,
        AddressBookRecordProperty.organizationName
    ]
}


public protocol AddressBookQueryBuilder {
    func keysToFetch(_ keys: [AddressBookRecordProperty]) -> AddressBookQueryBuilder
    func matchingPredicate(_ predicate: ContactPredicate) -> AddressBookQueryBuilder
    func query() throws -> [ContactProtocol]
    func queryAsync(_ completion: @escaping ContactResults)
}

internal class InternalAddressBookQueryBuilder<T: AddressBookProtocol>: AddressBookQueryBuilder {

    func queryAsync(_ completion: @escaping ([ContactProtocol]?, Error?) -> ()) {
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            do {
                let results = try self.query()
                DispatchQueue.main.async {
                    completion(results, nil)
                }
            }
            catch let e {
                DispatchQueue.main.async {
                    completion(nil, e)
                }
            }
            
            
        }
    }

    func matchingPredicate(_ predicate: (ContactProtocol) -> (Bool)) -> AddressBookQueryBuilder {
        self.predicate = predicate
        return self
    }

    
    internal var keysToFetch = AddressBookRecordProperty.allValues
    
    internal var predicate: ContactPredicate?
    
    internal let addressBook: T
    
    internal init(addressBook: T) {
        self.addressBook = addressBook
    }
    
    func keysToFetch(_ keys: [AddressBookRecordProperty]) -> AddressBookQueryBuilder {
        // always include ID
        self.keysToFetch = Array(Set(keys).union([AddressBookRecordProperty.identifier]))
        return self
    }
    
    func query() throws -> [ContactProtocol] {
        let contacts = try queryImpl()
        if let predicate = self.predicate {
            return contacts.filter(predicate)
            
        } else {
            return contacts
        }
    }
    
    func queryImpl() throws -> [ContactProtocol] {
        return [ContactProtocol]()
    }
    
   
}
