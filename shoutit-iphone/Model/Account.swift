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
    var apnsToken: String?
    private(set) var authData: AuthData?
    var loggedUser: LoggedUser? {
        didSet {
            if let userObject = loggedUser {
                self.userSubject.onNext(userObject)
                SecureCoder.writeObject(userObject, toFileAtPath: archivePath)
            }
        }
    }
    
    var guestUser: GuestUser? {
        didSet {
            if let userObject = guestUser {
                self.userSubject.onNext(userObject)
                SecureCoder.writeObject(userObject, toFileAtPath: archivePath)
            }
        }
    }
    
    var user: User? {
        return loggedUser ?? guestUser
    }
    
    var userSubject = BehaviorSubject<User?>(value: nil)
    
    func locationString() -> String {
        if let city = user?.location.city, state = user?.location.state, country = user?.location.country {
            return "\(city), \(state), \(country)"
        }
        
        return NSLocalizedString("Unknown Location", comment: "")
    }
    
    // convienience
    var isUserAuthenticated: Bool {
        return authData != nil && user != nil
    }
    
    var isUserLoggedIn: Bool {
        return isUserAuthenticated && user!.isGuest == false
    }
    
    // MARK - Lifecycle
    
    init() {
        
//        if let decoded: Decoded<User> = decode(json), let user = decoded.value {
//            Account.sharedInstance.user = user
//            completionHandler(.Success(user))
//        } else {
//            throw ParseError.User
//        }
        guestUser = SecureCoder.readObjectFromFile(archivePath)
        loggedUser = SecureCoder.readObjectFromFile(archivePath)
        assert(guestUser == nil || loggedUser == nil)
        
        if let data = keychain[data: authDataKey] {
            authData = SecureCoder.objectWithData(data)
        }
        
        if let authData = self.authData {
            APIManager.setAuthToken(authData.accessToken, tokenType: authData.tokenType)
        }
    }
    
    func loginUser<T: User>(user: T, withAuthData authData: AuthData) throws {
        
        // save
        let data = SecureCoder.dataWithJsonConvertible(authData)
        try keychain.set(data, key: authDataKey)
        
        // set instance vars
        self.authData = authData
        if let user = user as? LoggedUser {
            loggedUser = user
        } else if let user = user as? GuestUser {
            guestUser = user
        }
        
        // update apimanager token
        APIManager.setAuthToken(authData.accessToken, tokenType: authData.tokenType)
    }
    
    func logout() throws {
        try NSFileManager.defaultManager().removeItemAtPath(archivePath)
        try keychain.remove(authDataKey)
        loggedUser = nil
        guestUser = nil
        authData = nil
        APIManager.eraseAuthToken()
    }
}
