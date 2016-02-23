//
//  Account.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
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
                SecureCoder.writeObject(userObject, toFileAtPath: archivePath)
                self.userSubject.onNext(user)
            }
        }
    }
    
    var userSubject = BehaviorSubject<User?>(value: nil)
    
    func locationString() -> String {
        if let city = user?.location?.city, state = user?.location?.state, country = user?.location?.country {
            return "\(city), \(state), \(country)"
        }
        
        return NSLocalizedString("Unknown Location", comment: "")
    }
    
    // convienience
    var isUserLoggedIn: Bool {
        return authData != nil && user != nil
    }
    
    // MARK - Lifecycle
    
    init() {
        
        user = SecureCoder.readObjectFromFile(archivePath)
        if let data = keychain[data: authDataKey] {
            authData = SecureCoder.objectWithData(data)
        }
        
        if let authData = self.authData {
            APIManager.setAuthToken(authData.accessToken, tokenType: authData.tokenType)
        }
    }
    
    func loginUserWithAuthData(authData: AuthData) throws {
        
        // save
        let data = SecureCoder.dataWithJsonConvertible(authData)
        try keychain.set(data, key: authDataKey)
        SecureCoder.writeObject(authData.user, toFileAtPath: archivePath)
        
        // set instance vars
        self.authData = authData
        self.user = authData.user
        
        // update apimanager token
        APIManager.setAuthToken(authData.accessToken, tokenType: authData.tokenType)
    }
    
    func logout() throws {
        try NSFileManager.defaultManager().removeItemAtPath(archivePath)
        try keychain.remove(authDataKey)
        user = nil
        authData = nil
        APIManager.eraseAuthToken()
    }
}
