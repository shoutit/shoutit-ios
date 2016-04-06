//
//  SecureCoder.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

class SecureCoder {
    
    // MARK: - WRITE
    
    static func writeObject<T: Encodable>(object: T, toFileAtPath path: String) {
        let json = object.encode()
        let dictionary = json.JSONObject()
        let success = NSKeyedArchiver.archiveRootObject(dictionary, toFile: path)
        assert(success)
    }
    
    // MARK: - READ
    
    static func readObjectFromFile<T: Decodable where T == T.DecodedType>(path: String) -> T? {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObjectWithFile(path) else {
            return nil
        }
        
        let decoded: Decoded<T> = Argo.decode(contents)
        return decoded.value
    }
    
    
    // MARK: - TO DATA
    
    static func dataWithJsonConvertible<T: Encodable>(object: T) -> NSData {
        
        let json = object.encode()
        let dictionary = json.JSONObject()
        return NSKeyedArchiver.archivedDataWithRootObject(dictionary)
    }
    
    // MARK: - FROM DATA
    
    static func objectWithData<T: Decodable where T == T.DecodedType>(data: NSData) -> T? {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObjectWithData(data) else {
            return nil
        }
        
        let decoded: Decoded<T> = Argo.decode(contents)
        return decoded.value
    }
}
