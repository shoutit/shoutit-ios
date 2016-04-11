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
    
    private let disposeBag = DisposeBag()
    
    // public consts
    lazy var userDirectory: String = {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let userDirecotryPath = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent("user").path!
        if !NSFileManager.defaultManager().fileExistsAtPath(userDirecotryPath) {
            try! NSFileManager.defaultManager().createDirectoryAtPath(userDirecotryPath, withIntermediateDirectories: false, attributes: nil)
        }
        return userDirecotryPath
    }()
    
    // private consts
    lazy private var archivePath: String = {[unowned self] in
        let fileURL = NSURL(fileURLWithPath: self.userDirectory).URLByAppendingPathComponent("user.data")
        return fileURL.path!
    }()
    private let authDataKey = "authData"
    lazy private var keychain: Keychain = {
        return Keychain(service: "com.shoutit-iphone")
    }()
    
    // data
    var apnsToken: String? {
        didSet {
            self.updateAPNSIfNeeded()
        }
    }
    private(set) var authData: AuthData? {
        didSet {
            self.loginSubject.onNext()
        }
    }
    var loggedUser: DetailedProfile? {
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
    
    var userSubject = BehaviorSubject<User?>(value: nil) // triggered on login and user update
    var loginSubject: PublishSubject<Void> = PublishSubject() // triggered on login
    
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
        if let user = user as? DetailedProfile {
            loggedUser = user
        } else if let user = user as? GuestUser {
            guestUser = user
        }
        
        // update apimanager token
        APIManager.setAuthToken(authData.accessToken, tokenType: authData.tokenType)
    }
    
    
    func logout() throws {
        try removeFilesFromUserDirecotry()
        try keychain.remove(authDataKey)
        loggedUser = nil
        guestUser = nil
        authData = nil
        APIManager.eraseAuthToken()
    }
    
    // MARK: - Helpers
    
    private func removeFilesFromUserDirecotry() throws {
        guard NSFileManager.defaultManager().fileExistsAtPath(userDirectory) else { return }
        let paths = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(userDirectory)
        for p in paths {
            let fullPath = NSURL(fileURLWithPath: userDirectory).URLByAppendingPathComponent(p).path!
            try NSFileManager.defaultManager().removeItemAtPath(fullPath)
        }
    }
    
    func updateAPNSIfNeeded() {
        guard let user = self.user else {
            return
        }
        
        if let apnsToken = self.apnsToken {
            let params = APNParams(tokens: PushTokens(apns: apnsToken, gcm: nil))
            
            APIProfileService.updateAPNsWithUsername(user.username, withParams: params).subscribe({ (event) in
                switch event {
                case .Next(let profile):
                    print(profile)
                    break;
                case .Error(let error):
                    debugPrint(error)
                default: break
                }
            }).addDisposableTo(disposeBag)
        }
    }
}
