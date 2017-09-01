//
//  SecureCoder.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

final class SecureCoder {
    
    // MARK: - WRITE
    
    static func writeObject<T: JSONEncodable>(_ object: T, toFileAtPath path: String) {
        do {
            let json = try object.toJSON()
            NSKeyedArchiver.archiveRootObject(json, toFile: path)
        
        } catch let error {
            assertionFailure(error.message)
        }
        
    }
    
    // MARK: - READ
    
    static func readObjectFromFile<T: JSONDecodable>(_ path: String) -> T? {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? JSONObject else {
            return nil
        }
        
        let decoded: T? = try? T(object: contents)
        
        print(contents)
        print(decoded)
        
        return decoded
    }
    
    
    // MARK: - TO DATA
    
    static func dataWithJsonConvertible<T: JSONEncodable>(_ object: T) -> Data {
        
        guard let json = try? object.toJSON() else {
            return Data()
        }
        

        return NSKeyedArchiver.archivedData(withRootObject: json)
    }
    
    // MARK: - FROM DATA
    
    static func objectWithData<T: JSONDecodable>(_ data: Data) -> T? {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObject(with: data) as? JSONObject else {
            return nil
        }
        
        let decoded: T? = try? T(object: contents)
        
        return decoded
    }
}
