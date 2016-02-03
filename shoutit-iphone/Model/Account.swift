//
//  Account.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import PureJsonSerializer

final class Account {
    
    // singleton
    static let sharedInstance = Account()
    
    // private consts
    lazy private var archivePath: String = {
        let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let directoryURL = NSURL(fileURLWithPath: directory).URLByAppendingPathComponent("account.usr")
        return directoryURL.absoluteString
    }()
    
    // data
    private(set) var authData: AuthData?
    
    // convienience
    var isUserLoggedIn: Bool {
        return authData != nil
    }
    
    // MARK - Lifecycle
    
    init() {
        
        // try to restore auth data object
        do {
            let json = try SecureCoder.readJsonFromFile(archivePath)
            if let json = json {
                authData = try AuthData(js: json)
            }
        } catch let error as ParseError {
            fatalError(error.reason)
        } catch {
            fatalError("Auth data serialization error")
        }
        
        if let authData = self.authData {
            APIManager.setAuthToken(authData.accessToken, tokenType: authData.tokenType)
        }
    }
    
    func loginUserWithAuthData(authData: AuthData) throws {
        try SecureCoder.writeJsonConvertibleToFile(authData, toPath: archivePath)
        self.authData = authData
        APIManager.setAuthToken(authData.accessToken, tokenType: authData.tokenType)
    }
    
    func logout() throws {
        let fileManager = NSFileManager.defaultManager()
        try fileManager.removeItemAtPath(archivePath)
        APIManager.eraseAuthToken()
    }
}
