//
//  Account.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import PureJsonSerializer
import KeychainAccess
import RxSwift

final class Account {
    
    // singleton
    static let sharedInstance = Account()
    
    // private consts
    lazy private var archivePath: String = {
        let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let directoryURL = NSURL(fileURLWithPath: directory).URLByAppendingPathComponent("user.data")
        return directoryURL.path!
    }()
    
    private let authDataKey = "authData"
    
    lazy private var keychain: Keychain = {
        return Keychain(service: "com.shoutit-iphone")
    }()
    
    // data
    private(set) var authData: AuthData?
    
    var user: User? {
        didSet {
            if let userObject = user {
                _ = try? SecureCoder.writeJsonConvertibleToFile(userObject, toPath: archivePath)
                self.userSubject.onNext(user)
            }
        }
    }
    
    var userSubject = BehaviorSubject<User?>(value: nil)
    
    func locationString() -> String {
        if let location = user?.location.address {
            return location
        }
        
        return NSLocalizedString("Unknown Location", comment: "")
    }
    
    // convienience
    var isUserLoggedIn: Bool {
        return authData != nil && user != nil
    }
    
    // MARK - Lifecycle
    
    init() {
        
        // try to restore auth data object
        do {
            
            // get user
            let json = try SecureCoder.readJsonFromFile(archivePath)
            if let json = json {
                user = try User(js: json)
            }
            
            // get auth data
            let data = keychain[data: authDataKey]
            if let data = data, let json = try SecureCoder.jsonWithNSData(data) {
                authData = try AuthData(js: json)
            }
            
        }  catch {
            assert(false, "Error while unarchiving user data")
            _ = try? logout()
        }
        
        if let authData = self.authData {
            APIManager.setAuthToken(authData.accessToken, tokenType: authData.tokenType)
        }
    }
    
    func loginUserWithAuthData(authData: AuthData) throws {
        
        // save
        let data = try SecureCoder.dataWithJsonConvertible(authData)
        try keychain.set(data, key: authDataKey)
        try SecureCoder.writeJsonConvertibleToFile(authData.user, toPath: archivePath)
        
        // set instance vars
        self.authData = authData
        self.user = authData.user
        
        // update apimanager token
        APIManager.setAuthToken(authData.accessToken, tokenType: authData.tokenType)
    }
    
    func logout() throws {
        try NSFileManager.defaultManager().removeItemAtPath(archivePath)
        try keychain.remove(authDataKey)
        APIManager.eraseAuthToken()
    }
}
