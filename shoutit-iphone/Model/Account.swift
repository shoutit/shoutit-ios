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
    
    enum UserModel {
        case Logged(user: DetailedProfile)
        case Guest(user: GuestUser)
        
        var user: User {
            switch self {
            case .Logged(let user): return user
            case .Guest(let user): return user
            }
        }
    }
    
    // singleton
    static let sharedInstance = Account()
    lazy var twilioManager: Twilio = {[unowned self] in
        return Twilio(account: self)
    }()
    lazy var pusherManager: PusherClient = {[unowned self] in
        return PusherClient(account: self)
    }()
    
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
    
    private(set) var userModel: UserModel? {
        didSet {
            switch userModel {
            case .Some(.Logged(let userObject)):
                userSubject.onNext(userObject)
                statsSubject.onNext(userObject.stats)
                updateApplicationBadgeNumberWithStats(userObject.stats)
                SecureCoder.writeObject(userObject, toFileAtPath: archivePath)
                updateAPNSIfNeeded()
            case .Some(.Guest(let userObject)):
                userSubject.onNext(userObject)
                statsSubject.onNext(nil)
                updateApplicationBadgeNumberWithStats(nil)
                SecureCoder.writeObject(userObject, toFileAtPath: archivePath)
                updateAPNSIfNeeded()
            default:
                statsSubject.onNext(nil)
                updateApplicationBadgeNumberWithStats(nil)
            }
        }
    }
    
    var user: User? {
        switch userModel {
        case .Some(.Logged(let userObject)): return userObject
        case .Some(.Guest(let userObject)): return userObject
        default: return nil
        }
    }
    
    // helper vars
    private let disposeBag = DisposeBag()
    let userSubject = BehaviorSubject<User?>(value: nil) // triggered on login and user update
    let loginSubject: PublishSubject<Void> = PublishSubject() // triggered on login
    let statsSubject = BehaviorSubject<ProfileStats?>(value: nil)
    private var updatingAPNS = false
    
    // convienience
    var isUserAuthenticated: Bool {
        return authData != nil && user != nil
    }
    
    var isUserLoggedIn: Bool {
        return isUserAuthenticated && user!.isGuest == false
    }
    
    // MARK - Lifecycle
    
    private init() {
        
        if let guest: GuestUser = SecureCoder.readObjectFromFile(archivePath) {
            userModel = .Guest(user: guest)
        } else if let loggedUser: DetailedProfile = SecureCoder.readObjectFromFile(archivePath) {
            userModel = .Logged(user: loggedUser)
        }
        
        guard let user = user else { return }
        guard let data = keychain[data: authDataKey] else { return }
        guard let authData: AuthData = SecureCoder.objectWithData(data) else { return }
        
        self.authData = authData
        APIManager.setAuthToken(authData.apiToken)
        updateApplicationBadgeNumberWithStats((user as? DetailedProfile)?.stats)
        configureTwilioAndPusherServices()
        
        userSubject.onNext(user)
    }
    
    func locationString() -> String {
        if let city = user?.location.city, state = user?.location.state, country = user?.location.country {
            return "\(city), \(state), \(country)"
        }
        
        return NSLocalizedString("Unknown Location", comment: "")
    }
    
    func loginUser<T: User>(user: T, withAuthData authData: AuthData) throws {
        
        // save
        let data = SecureCoder.dataWithJsonConvertible(authData)
        try keychain.set(data, key: authDataKey)
        
        // auth
        self.authData = authData
        
        APIManager.setAuthToken(authData.apiToken)
        updateUserWithModel(user)
        configureTwilioAndPusherServices()
    }
    
    func updateUserWithModel<T: User>(user: T) {
        if let user = user as? DetailedProfile {
            userModel = .Logged(user: user)
        } else if let user = user as? GuestUser {
            userModel = .Guest(user: user)
        }
    }
    
    func logout() throws {
        APIProfileService.nullifyPushTokens().subscribeNext{}.addDisposableTo(disposeBag)
        try clearUserData()
        GIDSignIn.sharedInstance().signOut()
    }
    
    func clearUserData() throws {
        try self.removeFilesFromUserDirecotry()
        try self.keychain.remove(self.authDataKey)
        self.userModel = nil
        self.authData = nil
        APIManager.eraseAuthToken()
        pusherManager.disconnect()
        twilioManager.disconnect()
    }
    
    func fetchUserProfile() {
        guard case .Logged(let user)? = userModel where isUserLoggedIn else { return }
        
        let observable: Observable<DetailedProfile> = APIProfileService.retrieveProfileWithUsername(user.username)
        observable.subscribe{ (event) in
            switch event {
            case .Next(let profile):
                self.userModel = .Logged(user: profile)
            case .Error(let error): debugPrint(error)
            default: break
            }
            }.addDisposableTo(disposeBag)
    }
    
    func updateStats(stats: ProfileStats) {
        guard case .Logged(let user)? = userModel else { return }
        self.userModel = .Logged(user: user.updatedProfileWithStats(stats))
        self.statsSubject.onNext(stats)
    }
}

private extension Account {
    
    private func updateApplicationBadgeNumberWithStats(stats: ProfileStats?) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = ((stats?.unreadNotificationsCount) ?? 0) + ((stats?.unreadConversationCount) ?? 0)
    }
    
    private func configureTwilioAndPusherServices() {
        
        switch userModel {
        case .Some(.Logged(_)):
            guard let authData = authData else { assertionFailure(); return; }
            pusherManager.setAuthorizationToken(authData.apiToken)
            _ = twilioManager
        default:
            pusherManager.disconnect()
        }
    }
    
    private func removeFilesFromUserDirecotry() throws {
        guard NSFileManager.defaultManager().fileExistsAtPath(userDirectory) else { return }
        let paths = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(userDirectory)
        for p in paths {
            let fullPath = NSURL(fileURLWithPath: userDirectory).URLByAppendingPathComponent(p).path!
            try NSFileManager.defaultManager().removeItemAtPath(fullPath)
        }
    }
    
    private func updateAPNSIfNeeded() {
        
        guard let user = self.user, apnsToken = self.apnsToken where apnsToken != user.pushTokens?.apns && !updatingAPNS else { return }
        
        updatingAPNS = true
        
        let params = APNParams(tokens: PushTokens(apns: apnsToken, gcm: nil))
        
        if case .Guest(let guest)? = userModel {
            let observable: Observable<GuestUser> = APIProfileService.updateAPNsWithUsername(guest.username, withParams: params)
            observable
                .subscribe{ (event) in
                    self.updatingAPNS = false
                    switch event {
                    case .Next(let profile): self.updateUserWithModel(profile)
                    default: break
                    }
                }
                .addDisposableTo(disposeBag)
            
        }
        else if case .Logged(let user)? = userModel {
            let observable: Observable<DetailedProfile> = APIProfileService.updateAPNsWithUsername(user.username, withParams: params)
            observable
                .subscribe{ (event) in
                    self.updatingAPNS = false
                    switch event {
                    case .Next(let profile): self.updateUserWithModel(profile)
                    default: break
                    }
                }
                .addDisposableTo(disposeBag)
        }
    }
}
