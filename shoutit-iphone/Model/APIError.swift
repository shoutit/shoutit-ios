//
//  APIError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct APIError {
    let code: Int
    let message: String
    let developerMessage: String
    let requestId: String
    let errors: [APIDetailedError]
}

extension APIError: Decodable {
    
    public static func decode(_ j: JSON) -> Decoded<APIError> {
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
    public var userMessage: String {
        
        guard let detailedError = errors.first else {
            return message
        }
        
        guard var location = detailedError.location?.components(separatedBy: ".").last else {
            return detailedError.message
        }
        
        location = String(location.characters.map{$0 == "_" ? " " : $0})
        
        return ("\(location.capitalized): \(detailedError.message)")
    }
}

public struct APIDetailedError {
    let reason: String?
    let message: String
    let location: String?
    let locationType: String?
}

extension APIDetailedError: Decodable {
    
    public static func decode(_ j: JSON) -> Decoded<APIDetailedError> {
        return curry(APIDetailedError.init)
            <^> j <|? "reason"
            <*> j <| "message"
            <*> j <|? "location"
            <*> j <|? "location_type"
    }
}
