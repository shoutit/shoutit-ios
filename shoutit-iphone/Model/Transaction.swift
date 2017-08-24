//
//  Transaction.swift
//  shoutit
//
//  Created by Piotr Bernad on 13/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct Transaction: Hashable, Equatable {
    
    public let id: String
    public let createdAt: Int
    
    public let type: String
    public let object:  AttachedObject?
    public let display: Display?
    
    public let webPath: String?
    public let appPath: String?
    
    public var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    public func readCopy() -> Transaction {
        return Transaction(id: self.id, createdAt: self.createdAt, type: self.type, object: self.object, display: self.display, webPath: self.webPath, appPath:self.appPath)
    }
}

extension Transaction: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        type = try decoder.decode("type")
        createdAt = try decoder.decode("created_at")
        self.object = try decoder.decode("attached_object")
        display = try decoder.decode("display")
        webPath = try decoder.decode("web_url")
        appPath = try decoder.decode("app_url")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(type, key: "type")
            try encoder.encode(createdAt, key: "created_at")
            try encoder.encode(object, key: "attached_object")
            try encoder.encode(display, key: "display")
            try encoder.encode(webPath, key: "web_url")
            try encoder.encode(appPath, key: "app_url")
        })
    }
}

public func ==(lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.id == rhs.id
}
