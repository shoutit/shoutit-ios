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
        let json = object.encode()
        let dictionary = json.JSONObject()
        let success = NSKeyedArchiver.archiveRootObject(dictionary, toFile: path)
        assert(success)
    }
    
    // MARK: - READ
    
    static func readObjectFromFile<T: JSONDecodable>(_ path: String) -> T? where T == T.DecodedType {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObject(withFile: path) else {
            return nil
        }
        
        let decoded: Decoded<T> = Argo.decode(contents)
        
        print(contents)
        print(decoded.value)
        
        return decoded.value
    }
    
    
    // MARK: - TO DATA
    
    static func dataWithJsonConvertible<T: JSONEncodable>(_ object: T) -> Data {
        
        let json = object.encode()
        let dictionary = json.JSONObject()
        return NSKeyedArchiver.archivedData(withRootObject: dictionary)
    }
    
    // MARK: - FROM DATA
    
    static func objectWithData<T: JSONDecodable>(_ data: Data) -> T? {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObject(with: data) else {
            return nil
        }
        
        
        
        let decoded: Decoded<T> = Argo.decode(contents)
        return decoded.value
    }
}
