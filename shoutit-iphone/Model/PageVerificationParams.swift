//
//  PageVerificationParams.swift
//  shoutit
//
//  Created by Piotr Bernad on 12/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

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
            commonParams["business_name"] = businessName
        }
        
        if let contactPerson = contactPerson {
            commonParams["contact_person"] = contactPerson
        }
        
        if let contactNumber = contactNumber {
            commonParams["contact_number"] = contactNumber
        }
        
        if let businessEmail = businessEmail {
            commonParams["business_email"] = businessEmail
        }
        
        if let location = location {
            commonParams["location"] = location.encode().JSONObject()
        }
        
        if let images = images {
            commonParams["images"] = images
        }
        
        return commonParams
    }
}