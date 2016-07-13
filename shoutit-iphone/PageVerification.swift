//
//  PageVerification.swift
//  shoutit
//
//  Created by Piotr Bernad on 13.07.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct PageVerification {
    public let businessName: String
    public let businessEmail: String
    
    public let message: String?
    public let status: String
    
    public let contactNumber: String
    public let contactPerson: String
    
    public let images: [String]?
    
}

extension PageVerification: Decodable {
    
    public static func decode(j: JSON) -> Decoded<PageVerification> {
        let function = curry(PageVerification.init)
        return function
            <^> j <| "business_name"
            <*> j <| "business_email"
            <*> j <|? "success"
            <*> j <| "status"
            <*> j <| "contact_number"
            <*> j <| "contact_person"
            <*> j <||? "images"
    }
}


