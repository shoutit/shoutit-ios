//
//  PageVerificationParams.swift
//  shoutit
//
//  Created by Piotr Bernad on 12/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit
import JSONCodable

extension JSONEncodable {
    public func encode() -> JSONObject {
        return (try! self.toJSON() as? JSONObject) ?? JSONObject()
    }
}
extension Dictionary where Key == String {
    public func JSONObject() -> AnyObject {
        return self as AnyObject
    }
}


struct PageVerificationParams : Params {
    var businessName : String?
    var contactPerson : String?
    var contactNumber : String?
    var businessEmail : String?
    var location : Address?
    var images : [String]?
 
    var params: [String : AnyObject] {
        var commonParams : [String : AnyObject] = [:]
        
        if let businessName = businessName {
            commonParams["business_name"] = businessName as AnyObject
        }
        
        if let contactPerson = contactPerson {
            commonParams["contact_person"] = contactPerson as AnyObject
        }
        
        if let contactNumber = contactNumber {
            commonParams["contact_number"] = contactNumber as AnyObject
        }
        
        if let businessEmail = businessEmail {
            commonParams["business_email"] = businessEmail as AnyObject
        }
        
        if let location = location {
            commonParams["location"] = location.encode().JSONObject()
        }
        
        if let images = images {
            commonParams["images"] = images as AnyObject
        }
        
        return commonParams
    }
}
