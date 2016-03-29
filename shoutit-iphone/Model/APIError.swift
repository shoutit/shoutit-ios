//
//  APIError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct APIError {
    let code: Int
    let message: String
    let developerMessage: String
    let requestId: String
    let errors: [APIDetailedError]
}

extension APIError: Decodable {
    
    static func decode(j: JSON) -> Decoded<APIError> {
        let a = curry(APIError.init)
            <^> j <| "code"
            <*> j <| "message"
            <*> j <| "developer_message"
        return  a
            <*> j <| "request_id"
            <*> j <|| "errors"
    }
}

extension APIError: ShoutitError {
    var userMessage: String {
        if let detailedMessage = errors.first?.message {
            return detailedMessage
        }
        return message
    }
}

struct APIDetailedError {
    let reason: String
    let message: String
    let location: String?
    let locationType: String?
}

extension APIDetailedError: Decodable {
    
    static func decode(j: JSON) -> Decoded<APIDetailedError> {
        return curry(APIDetailedError.init)
            <^> j <| "reason"
            <*> j <| "message"
            <*> j <|? "location"
            <*> j <|? "location_type"
    }
}
