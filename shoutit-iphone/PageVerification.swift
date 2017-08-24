//
//  PageVerification.swift
//  shoutit
//
//  Created by Piotr Bernad on 13.07.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct PageVerification {
    public let businessName: String
    public let businessEmail: String
    
    public let message: String?
    public let status: String
    
    public let contactNumber: String
    public let contactPerson: String
    
    public let images: [String]?
    
}


extension PageVerification: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        businessName = try decoder.decode("business_name")
        businessEmail = try decoder.decode("business_email")
        message = try decoder.decode("success")
        status = try decoder.decode("status")
        contactNumber = try decoder.decode("contact_number")
        contactPerson = try decoder.decode("contact_person")
        images = try decoder.decode("images")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(businessName, key: "business_name")
            try encoder.encode(businessEmail, key: "business_email")
            try encoder.encode(message, key: "success")
            try encoder.encode(status, key: "status")
            try encoder.encode(contactNumber, key: "contact_number")
            try encoder.encode(contactPerson, key: "contact_person")
            try encoder.encode(images, key: "images")
        })
    }
}
