//
//  Transaction.swift
//  shoutit
//
//  Created by Piotr Bernad on 13/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct Transaction: Decodable, Hashable, Equatable {
    
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
    
    public static func decode(j: JSON) -> Decoded<Transaction> {
        let a = curry(Transaction.init)
            <^> j <| "id"
            <*> j <| "created_at"
        let b = a
            <*> j <| "type"
            <*> j <|? "attached_object"
            <*> j <|? "display"
        let c = b
            <*> j <|? "web_url"
            <*> j <|? "app_url"
        
        return c
    }
    
    public func readCopy() -> Transaction {
        return Transaction(id: self.id, createdAt: self.createdAt, type: self.type, object: self.object, display: self.display, webPath: self.webPath, appPath:self.appPath)
    }
}

public func ==(lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.id == rhs.id
}
