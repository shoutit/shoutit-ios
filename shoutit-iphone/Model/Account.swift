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
        case Logged(user: DetailedUserProfile)
        case Page(user: DetailedUserProfile, page: DetailedPageProfile)
        case Guest(user: GuestUser)
    }
    
    // singleton
    static let sharedInstance = Account()
    
    // public
    let userSubject = BehaviorSubject<User?>(value: nil) // triggered on login and user update
    let loginStateSubject = BehaviorSubject<LoginState?>(value: nil)
    let loginSubject: PublishSubject<AuthData?> = PublishSubject() // triggered on login
    let statsSubject = BehaviorSubject<ProfileStats?>(value: nil)
    lazy var twilioManager: Twilio = {[unowned self] in Twilio(account: self) }()
    lazy var pusherManager: PusherClient = {[unowned self] in PusherClient(account: self) }()
    lazy var facebookManager: FacebookManager = {[unowned self] in FacebookManager(account: self) }()
    lazy var linkedAccountsManager: LinkedAccountsManager = {[unowned self] in LinkedAccountsManager(account: self) }()
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
            loginStateSubject.onNext(loginState)
            switch loginState {
            case .Some(.Logged(let userObject)):
                userSubject.onNext(userObject)
                statsSubject.onNext(userObject.stats)
                updateApplicationBadgeNumberWithStats(userObject.stats)
                SecureCoder.writeObject(userObject, toFileAtPath: archivePath)
                updateAPNSIfNeeded()
                facebookManager.checkExpiryDateWithProfile(userObject)
            case .Some(.Page(let user, let page)):
                userSubject.onNext(page)
                statsSubject.onNext(page.stats)
                updateApplicationBadgeNumberWithStats(page.stats)
                SecureCoder.writeObject(page, toFileAtPath: archivePath)
                updateAPNSIfNeeded()
                facebookManager.checkExpiryDateWithProfile(user)
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
        case .Some(.Page(_, let page)): return page
        case .Some(.Guest(let userObject)): return userObject
        default: return nil
        }
    }
    
    var profile: Profile? {
        if let detailed = user as? DetailedProfile {
            return Profile.profileWithUser(detailed)
        }
        
        if let basic = user as? Profile {
            return basic
        }
        
        if let guest = user as? GuestUser {
            return Profile.profileWithGuest(guest)
        }
        
        assertionFailure("Account Profile is missing. Something went wrong")
        
        return nil
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
        if let page : DetailedPageProfile = SecureCoder.readObjectFromFile(archivePath) {
            if let admin = page.admin {
                loginState = .Page(user: admin.value, page: page)
            }
        }
        
        if let model: DetailedUserProfile = SecureCoder.readObjectFromFile(archivePath) {
            loginState = .Logged(user: model)
        }
        
        if let guest: GuestUser = SecureCoder.readObjectFromFile(archivePath) {
            loginState = .Guest(user: guest)
        }
        
        guard let user = user else { return }
        guard let data = keychain[data: authDataKey] else { return }
        guard let authData: AuthData = SecureCoder.objectWithData(data) else { return }
        
        self.authData = authData
        loginSubject.onNext(authData)
        updateTokenWithAuthData(authData, user: user)
        updateApplicationBadgeNumberWithStats((user as? DetailedUserProfile)?.stats)
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
        updateTokenWithAuthData(authData, user: user)
        updateUserWithModel(user, force: true)
        configureTwilioAndPusherServices()
    }
    
    func switchToPage(page: DetailedPageProfile) {
        guard case .Some(.Logged(let user)) = loginState, let authData = authData where user.type == .User else {
            fatalError("User must be logged in to switch to page")
        }
        precondition(page.type == .Page)
        APIManager.setAuthToken(authData.apiToken, pageId: page.id)
        loginSubject.onNext(authData)
        loginState = .Page(user: user, page: page)
        twilioManager.reconnect()
    }
    
    func switchToUser() {
        guard case .Some(.Page(let user , _)) = loginState, let authData = authData else {
            fatalError("User must use app as page to switch back to user")
        }
        APIManager.setAuthToken(authData.apiToken, pageId: nil)
        loginSubject.onNext(authData)
        loginState = .Logged(user: user)
        twilioManager.reconnect()
    }
    
    func updateUserWithModel<T: User>(model: T, force: Bool = false) {
        if let model = model as? DetailedUserProfile where model.type == .User {
            switch (loginState, force) {
            case (.Logged(_)?, _), (.None, _), (_, true): loginState = .Logged(user: model)
            default: break
            }
        }
        else if let model = model as? DetailedPageProfile, admin = model.admin where model.type == .Page {
            switch (loginState, force) {
            case (.Page(_)?, _), (.None, _), (_, true): loginState = .Page(user: admin.value, page: model)
            default: break
            }
        }
        else if let model = model as? GuestUser {
            switch (loginState, force) {
            case (.Guest(_)?, _), (.None, _), (_, true): loginState = .Guest(user: model)
            default: break
            }
        }
    }
    
    private func updateTokenWithAuthData(authData: AuthData, user: User) {
        if let page = user as? DetailedProfile where page.type == .Page {
            APIManager.setAuthToken(authData.apiToken, pageId: page.id)
        } else {
            APIManager.setAuthToken(authData.apiToken, pageId: nil)
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
        
        let observable: Observable<DetailedUserProfile> = APIProfileService.retrieveProfileWithUsername(user.username)
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
            let observable: Observable<DetailedUserProfile> = APIProfileService.updateAPNsWithUsername(user.username, withParams: params)
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
