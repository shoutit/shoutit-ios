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
    
    static func writeJson(json: Json, toFileAtPath path: String) {
        let string = json.serialize()
        
        let success = NSKeyedArchiver.archiveRootObject(string as NSString, toFile: path)
        print(string)
        print(success)
    }
    
    static func writeJsonConvertibleToFile(object: JsonConvertibleType, toPath path: String) throws {
        let json = try object.jsonRepresentation()
        writeJson(json, toFileAtPath: path)
    }
    
    static func readJsonFromFile(path: String) throws -> Json? {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObjectWithFile(path) else {
            return nil
        }
        
        guard let string = contents as? String where string.characters.count > 0 else {
            return nil
        }
        
        return try Json.deserialize(string)
    }
}
