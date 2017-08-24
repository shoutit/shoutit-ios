//
//  APIError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct APIError {
    let code: Int
    let message: String
    let developerMessage: String
    let requestId: String
    let errors: [APIDetailedError]
}

extension APIError: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        code = try decoder.decode("code")
        message = try decoder.decode("message")
        developerMessage = try decoder.decode("developer_message")
        requestId = try decoder.decode("request_id")
        errors = try decoder.decode("errors")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(code, key: "code")
            try encoder.encode(message, key: "message")
            try encoder.encode(developerMessage, key: "developer_message")
            try encoder.encode(requestId, key: "request_id")
            try encoder.encode(errors, key: "errors")
        })
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


extension APIDetailedError: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        reason = try decoder.decode("reason")
        message = try decoder.decode("message")
        location = try decoder.decode("location")
        locationType = try decoder.decode("name")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(reason, key: "reason")
            try encoder.encode(message, key: "message")
            try encoder.encode(location, key: "location")
            try encoder.encode(locationType, key: "location_type")
        })
    }
}
