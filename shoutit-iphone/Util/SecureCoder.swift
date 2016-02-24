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
    
    static func writeObject(object: Encodable, toFileAtPath path: String) {
        let json = object.encode()
        let dictionary = json.JSONObject()
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: path)
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
    
    static func dataWithJsonConvertible(object: Encodable) -> NSData {
        
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

// MARK: - User

extension SecureCoder {
    
    static func readUserFromFile(path: String) -> User? {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [String : AnyObject] else {
            return nil
        }
        
        return userWithDictionary(contents)
    }
    
    static func userWithData(data: NSData) -> User? {
        
        guard let contents = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String : AnyObject] else {
            return nil
        }
        
        return userWithDictionary(contents)
    }
    
    static func userWithDictionary(json: [String : AnyObject]) -> User? {
        
        guard let isGuest = (json["is_guest"] as? NSNumber)?.boolValue else {
            let decoded: Decoded<LoggedUser> = Argo.decode(json)
            return decoded.value
        }
        
        if isGuest {
            let decoded: Decoded<GuestUser> = Argo.decode(json)
            return decoded.value
        } else {
            let decoded: Decoded<LoggedUser> = Argo.decode(json)
            return decoded.value
        }
    }
}
