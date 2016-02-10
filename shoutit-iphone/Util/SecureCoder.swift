//
//  SecureCoder.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome
import PureJsonSerializer

class SecureCoder {
    
    // MARK: - WRITE
    
    static func writeJson(json: Json, toFileAtPath path: String) {
        let string = json.serialize()
        NSKeyedArchiver.archiveRootObject(string as NSString, toFile: path)
    }
    
    static func writeJsonConvertibleToFile(object: JsonConvertibleType, toPath path: String) throws {
        let json = try object.jsonRepresentation()
        writeJson(json, toFileAtPath: path)
    }
    
    // MARK: - READ
    
    static func readJsonFromFile(path: String) throws -> Json? {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObjectWithFile(path) else {
            return nil
        }
        
        guard let string = contents as? String where string.characters.count > 0 else {
            return nil
        }
        
        return try Json.deserialize(string)
    }
    
    // MARK: - TO DATA
    
    static func dataWithJsonConvertible(json: JsonConvertibleType) throws -> NSData {
        
        let json = try json.jsonRepresentation()
        let stringRepresentation = json.serialize()
        return NSKeyedArchiver.archivedDataWithRootObject(stringRepresentation)
    }
    
    // MARK: - FROM DATA
    
    static func jsonWithNSData(data: NSData) throws -> Json? {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObjectWithData(data) else {
            return nil
        }
        
        guard let string = contents as? String where string.characters.count > 0 else {
            return nil
        }
        
        return try Json.deserialize(string)
    }
}
