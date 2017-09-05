//
//  CNContactRecord.swift
//  ContactsPicker
//
//  Created by Piotr on 02/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import Contacts

// ref

//let cnMappings = [
//    AddressBookRecordLabel.LabelType.Main.rawValue : CNLabelPhoneNumberMain,
//    AddressBookRecordLabel.LabelType.Home.rawValue : CNLabelHome,
//    AddressBookRecordLabel.LabelType.Work.rawValue : CNLabelWork,
//    AddressBookRecordLabel.LabelType.Other.rawValue : CNLabelOther,
//    AddressBookRecordLabel.LabelType.PhoneiPhone.rawValue : CNLabelPhoneNumberiPhone,
//    AddressBookRecordLabel.LabelType.PhoneMobile.rawValue : CNLabelPhoneNumberMobile
//]
class CNContactRecord: ContactProtocol {
    
    internal let wrappedContact: CNMutableContact
    
    internal convenience init (cnContact: CNContact) {
        self.init(cnContact: cnContact.mutableCopy() as! CNMutableContact)
    }
    
    internal init (cnContact: CNMutableContact) {
        wrappedContact = cnContact
    }
    
    var identifier: String? = nil
//    {
//        get {
//            if wrappedContact.isKeyAvailable(CNContactIdentifierKey) {
//                return wrappedContact.identifier
//            } else {
//                return nil
//            }
//        }
//    }
    
    var firstName: String? = nil
//        get {
//            if wrappedContact.isKeyAvailable(CNContactGivenNameKey) {
//                return wrappedContact.givenName
//            } else {
//                return nil
//            }
//        }
//        set {
//            if let value = newValue {
//                wrappedContact.givenName = value
//            }
//        }
//    }
    
        var middleName: String? = nil
//        get {
//            if wrappedContact.isKeyAvailable(CNContactMiddleNameKey) {
//                return wrappedContact.middleName
//            } else {
//                return nil
//            }
//        }
//        set {
//            if let value = newValue {
//                wrappedContact.middleName = value
//            }
//        }
//    }
    
        var lastName: String?  = nil
//        get {
//            if wrappedContact.isKeyAvailable(CNContactFamilyNameKey) {
//                return wrappedContact.familyName
//            } else {
//                return nil
//            }
//
//        }
//        set {
//            if let value = newValue {
//                wrappedContact.familyName = value
//            }
//        }
//    }
    
        var organizationName: String? = nil
//        get {
//            if wrappedContact.isKeyAvailable(CNContactOrganizationNameKey) {
//                return wrappedContact.organizationName
//            } else {
//                return nil
//            }
//        }
//        set {
//            if let value = newValue {
//                wrappedContact.organizationName = value
//            }
//        }
//    }
    
        var phoneNumbers: [AddressBookRecordLabel]? = []
//        get {
//            if wrappedContact.isKeyAvailable(CNContactPhoneNumbersKey) {
//                return CNAdapter.convertCNLabeledValues(wrappedContact.phoneNumbers as! [CNLabeledValue<NSString>])
//            } else {
//                return nil
//            }
//            
//        }
//        set {
//            wrappedContact.phoneNumbers = CNAdapter.convertPhoneNumbers(newValue)
//        }
//    }
    
        var emailAddresses: [AddressBookRecordLabel]? = []
//        get {
//            if wrappedContact.isKeyAvailable(CNContactEmailAddressesKey) {
//                return CNAdapter.convertCNLabeledValues(wrappedContact.emailAddresses)
//            } else {
//                return nil
//            }
//        }
//        set {
//            wrappedContact.emailAddresses = CNAdapter.convertEmailAddresses(emailAddresses)
//        }
//    }
}


class CNAdapter {
    
    internal class func convertCNContactsToContactRecords(_ cnContacts: [CNContact]) -> [ContactProtocol] {
        return cnContacts.map({ (cnContact) -> ContactProtocol in
            return CNContactRecord(cnContact: cnContact)
        })
    }
    
    internal class func convertContactValuesToCNContact(_ contact: ContactProtocol) -> CNMutableContact {
        let cnContact = CNMutableContact()
        if let firstName = contact.firstName {
             cnContact.givenName = firstName
        }
        
        if let lastName = contact.lastName {
            cnContact.familyName = lastName
        }
        
        if let organizationName = contact.organizationName {
            cnContact.organizationName = organizationName
        }
        
        if let middleName = contact.middleName {
            cnContact.middleName = middleName
        }
       
//        cnContact.phoneNumbers = convertPhoneNumbers(contact.phoneNumbers)
//        cnContact.emailAddresses = convertEmailAddresses(contact.emailAddresses)
        
        return cnContact
    }
    
    fileprivate class func convertPhoneNumbers(_ phoneNumbers: [AddressBookRecordLabel]?) -> [CNLabeledValue<CNPhoneNumber>] {
        
//        guard let phoneNumbers = phoneNumbers else {
            return [CNLabeledValue]()
//        }
        
//        return phoneNumbers.map({
//            ( LabeledValue) -> CNLabeledValue<CNPhoneNumber> in
//            
//            let label = AddressBookRecordLabel.convertLabel(cnMappings, label: LabeledValue.label)
//            var phoneNumber: CNPhoneNumber
//            if let phoneNumberAsString = LabeledValue.value as? String {
//                phoneNumber = CNPhoneNumber(stringValue: phoneNumberAsString)
//            } else {
//                phoneNumber = CNPhoneNumber()
//            }
//            
//            return CNLabeledValue(label: label, value: phoneNumber)
//        })
    }
    
    fileprivate class func convertEmailAddresses(_ emailAddresses: [AddressBookRecordLabel]?) -> [CNLabeledValue<NSString>] {
        
//        guard let emailAddresses = emailAddresses else {
            return [CNLabeledValue]()
//        }
        
//        return emailAddresses.map({
//            ( LabeledValue) -> CNLabeledValue<NSString> in
//            
//            let label = AddressBookRecordLabel.convertLabel(cnMappings, label: LabeledValue.label)
//            let value = LabeledValue.value as! NSString
//            
//            return CNLabeledValue(label: label, value: value)
//        })
        
    }
    
    internal class func convertCNLabeledValues(_ cnLabeledValues: [CNLabeledValue<NSString>]) -> [AddressBookRecordLabel] {
        return [AddressBookRecordLabel]()
//        var abLabels = [AddressBookRecordLabel]()
//        
//        let mappings = DictionaryUtils.dictionaryWithSwappedKeysAndValues(cnMappings)
//        for cnLabeledValue in cnLabeledValues {
//            let label = AddressBookRecordLabel.convertLabel(mappings, label: cnLabeledValue.label)
//            let value = cnLabeledValue.valueAsString()
//            abLabels.append(
//                AddressBookRecordLabel(
//                    label: label,
//                    value: value as NSCopying & NSSecureCoding)
//            )
//        }
//        
//        return abLabels
    }
}
