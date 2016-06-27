//
//  Account.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit
import KeychainAccess

final class Account {
    
    enum LoginState {
        case Logged(user: DetailedProfile)
        case Page(user: DetailedProfile, page: Profile)
        case Guest(user: GuestUser)
    }
    
    // singleton
    static let sharedInstance = Account()
    
    // public
    let userSubject = BehaviorSubject<User?>(value: nil) // triggered on login and user update
    let loginSubject: PublishSubject<AuthData?> = PublishSubject() // triggered on login
    let statsSubject = BehaviorSubject<ProfileStats?>(value: nil)
    lazy var twilioManager: Twilio = {[unowned self] in Twilio(account: self) }()
    lazy var pusherManager: PusherClient = {[unowned self] in PusherClient(account: self) }()
    lazy var facebookManager: FacebookManager = {[unowned self] in FacebookManager(account: self) }()
    lazy var userDirectory: String = self.createUserDirectory()
    
    // private consts
    private lazy var archivePath: String = {[unowned self] in NSURL(fileURLWithPath: self.userDirectory).URLByAppendingPathComponent("user.data").path! }()
    private let authDataKey = "authData"
    private lazy var keychain: Keychain = { return Keychain(service: "com.shoutit-iphone") }()
    
    // helper vars
    private var updatingAPNS = false
    private let disposeBag = DisposeBag()
    
    // data
    var apnsToken: String? {
        didSet { self.updateAPNSIfNeeded() }
    }
    var invitationCode: String?
    
    private(set) var authData: AuthData?
    
    private(set) var loginState: LoginState? {
        didSet {
            switch loginState {
            case .Some(.Logged(let userObject)):
                userSubject.onNext(userObject)
                statsSubject.onNext(userObject.stats)
                updateApplicationBadgeNumberWithStats(userObject.stats)
                SecureCoder.writeObject(userObject, toFileAtPath: archivePath)
                updateAPNSIfNeeded()
                facebookManager.checkExpiryDateWithProfile(userObject)
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
        switch loginState {
        case .Some(.Logged(let userObject)): return userObject
        case .Some(.Page(let userObject, _)): return userObject
        case .Some(.Guest(let userObject)): return userObject
        default: return nil
        }
    }
    
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
            loginState = .Guest(user: guest)
        } else if let loggedUser: DetailedProfile = SecureCoder.readObjectFromFile(archivePath) {
            loginState = .Logged(user: loggedUser)
        }
        
        guard let user = user else { return }
        guard let data = keychain[data: authDataKey] else { return }
        guard let authData: AuthData = SecureCoder.objectWithData(data) else { return }
        
        self.authData = authData
        loginSubject.onNext(authData)
        APIManager.setAuthToken(authData.apiToken, pageId: nil)
        updateApplicationBadgeNumberWithStats((user as? DetailedProfile)?.stats)
        configureTwilioAndPusherServices()
        userSubject.onNext(user)
    }
    
    func loginUser<T: User>(user: T, withAuthData authData: AuthData) throws {
        
        // save
        let data = SecureCoder.dataWithJsonConvertible(authData)
        try keychain.set(data, key: authDataKey)
        
        // auth
        self.authData = authData
        loginSubject.onNext(authData)
        APIManager.setAuthToken(authData.apiToken, pageId: nil)
        updateUserWithModel(user)
        configureTwilioAndPusherServices()
    }
    
    func switchToPage(page: Profile) {
        guard case .Some(.Logged(let user)) = loginState, let authData = authData where user.type == .User else {
            fatalError("User must be logged in to switch to page")
        }
        precondition(page.type == .Page)
        APIManager.setAuthToken(authData.apiToken, pageId: page.id)
        loginSubject.onNext(authData)
        loginState = .Page(user: user, page: page)
    }
    
    func switchToUser() {
        guard case .Some(.Page(let user , _)) = loginState, let authData = authData else {
            fatalError("User must use app as page to switch back to user")
        }
        APIManager.setAuthToken(authData.apiToken, pageId: nil)
        loginSubject.onNext(authData)
        loginState = .Logged(user: user)
    }
    
    func updateUserWithModel<T: User>(user: T) {
        if let user = user as? DetailedProfile {
            loginState = .Logged(user: user)
        } else if let user = user as? GuestUser {
            loginState = .Guest(user: user)
        }
    }
    
    func logout() throws {
        APIProfileService.nullifyPushTokens().subscribeNext{}.addDisposableTo(disposeBag)
        try clearUserData()
        GIDSignIn.sharedInstance().signOut()
        facebookManager.logout()
    }
    
    func clearUserData() throws {
        try removeFilesFromUserDirecotry()
        try keychain.remove(self.authDataKey)
        loginState = nil
        authData = nil
        loginSubject.onNext(nil)
        APIManager.eraseAuthToken()
        pusherManager.disconnect()
        twilioManager.disconnect()
    }
}

extension Account {
    
    func locationString() -> String {
        if let city = user?.location.city, state = user?.location.state, country = user?.location.country {
            return "\(city), \(state), \(country)"
        }
        
        return NSLocalizedString("Unknown Location", comment: "")
    }
    
    func fetchUserProfile() {
        guard case .Logged(let user)? = loginState where isUserLoggedIn else { return }
        
        let observable: Observable<DetailedProfile> = APIProfileService.retrieveProfileWithUsername(user.username)
        observable.subscribe{ (event) in
            switch event {
            case .Next(let profile):
                self.loginState = .Logged(user: profile)
            case .Error(let error): debugPrint(error)
            default: break
            }
            }.addDisposableTo(disposeBag)
    }
    
    func updateStats(stats: ProfileStats) {
        guard case .Logged(let user)? = loginState else { return }
        self.loginState = .Logged(user: user.updatedProfileWithStats(stats))
        self.statsSubject.onNext(stats)
    }
}

private extension Account {
    
    private func updateApplicationBadgeNumberWithStats(stats: ProfileStats?) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = ((stats?.unreadNotificationsCount) ?? 0) + ((stats?.unreadConversationCount) ?? 0)
    }
    
    private func configureTwilioAndPusherServices() {
        
        switch loginState {
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
        
        if case .Guest(let guest)? = loginState {
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
        else if case .Logged(let user)? = loginState {
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
    
    private func createUserDirectory() -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let userDirecotryPath = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent("user").path!
        if !NSFileManager.defaultManager().fileExistsAtPath(userDirecotryPath) {
            try! NSFileManager.defaultManager().createDirectoryAtPath(userDirecotryPath, withIntermediateDirectories: false, attributes: nil)
        }
        return userDirecotryPath
    }
}
