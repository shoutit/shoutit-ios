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
import CocoaLumberjackSwift
import PaperTrailLumberjack

final class Account {
    
    enum LoginState {
        case logged(user: DetailedUserProfile)
        case page(user: DetailedUserProfile, page: DetailedPageProfile)
        case guest(user: GuestUser)
    }
    
    // singleton
    static let sharedInstance = Account()
    
    // public
    let userSubject = BehaviorSubject<User?>(value: nil) // triggered on login and user update
    let loginStateSubject = BehaviorSubject<LoginState?>(value: nil)
    let loginSubject: PublishSubject<AuthData?> = PublishSubject() // triggered on login
    
    let statsSubject = BehaviorSubject<ProfileStats?>(value: nil)
    let adminStatsSubject = BehaviorSubject<ProfileStats?>(value: nil)
    
    lazy var twilioManager: Twilio = {[unowned self] in Twilio(account: self) }()
    lazy var pusherManager: PusherClient = {[unowned self] in PusherClient(account: self) }()
    lazy var facebookManager: FacebookManager = {[unowned self] in FacebookManager(account: self) }()
    lazy var linkedAccountsManager: LinkedAccountsManager = {[unowned self] in LinkedAccountsManager(account: self) }()
    lazy var userDirectory: String = self.createUserDirectory()
    
    // private consts
    fileprivate lazy var archivePath: String = {[unowned self] in URL(fileURLWithPath: self.userDirectory).appendingPathComponent("user.data").path }()
    fileprivate let authDataKey = "authData"
    fileprivate lazy var keychain: Keychain = { return Keychain(service: "com.shoutit-iphone") }()
    
    // helper vars
    fileprivate var updatingAPNS = false
    fileprivate let disposeBag = DisposeBag()
    
    // data
    var apnsToken: String? {
        didSet { self.updateAPNSIfNeeded() }
    }
    var invitationCode: String?
    
    fileprivate(set) var authData: AuthData?
    
    fileprivate(set) var loginState: LoginState? {
        didSet {
            loginStateSubject.onNext(loginState)
            switch loginState {
            case .some(.logged(let userObject)):
                userSubject.onNext(userObject)
                statsSubject.onNext(userObject.stats)
                updateApplicationBadgeNumberWithStats(userObject.stats)
                SecureCoder.writeObject(userObject, toFileAtPath: archivePath)
                updateAPNSIfNeeded()
                facebookManager.checkExpiryDateWithProfile(userObject)
            case .some(.page(let user, let page)):
                userSubject.onNext(page)
                statsSubject.onNext(page.stats)
                adminStatsSubject.onNext(user.stats)
                updateApplicationBadgeNumberWithStats(page.stats)
                SecureCoder.writeObject(page, toFileAtPath: archivePath)
                updateAPNSIfNeeded()
                facebookManager.checkExpiryDateWithProfile(user)
            case .some(.guest(let userObject)):
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
        case .some(.logged(let userObject)): return userObject
        case .some(.page(_, let page)): return page
        case .some(.guest(let userObject)): return userObject
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
    
    fileprivate init() {
        if let page : DetailedPageProfile = SecureCoder.readObjectFromFile(archivePath) {
            if let admin = page.admin {
                loginState = .page(user: admin.value, page: page)
            }
        }
        
        if let model: DetailedUserProfile = SecureCoder.readObjectFromFile(archivePath) {
            loginState = .logged(user: model)
        }
        
        if let guest: GuestUser = SecureCoder.readObjectFromFile(archivePath) {
            loginState = .guest(user: guest)
        }
        
        guard let user = user else { return }
        guard let data = keychain[data: authDataKey] else { return }
        guard let authData: AuthData = SecureCoder.objectWithData(data) else { return }
        
        self.authData = authData
        APIManager.authData = authData
        loginSubject.onNext(authData)
        updateTokenWithAuthData(authData, user: user)
        updateApplicationBadgeNumberWithStats((user as? DetailedUserProfile)?.stats)
        configureTwilioAndPusherServices()
        checkPaperTrailLogger()
        userSubject.onNext(user)
    }
    

        
    func loginUser<T: User>(_ user: T, withAuthData authData: AuthData) throws {
        
        // save
        let data = SecureCoder.dataWithJsonConvertible(authData)
        try keychain.set(data, key: authDataKey)
        
        // auth
        self.authData = authData
        APIManager.authData = authData
        loginSubject.onNext(authData)
        updateTokenWithAuthData(authData, user: user)
        updateUserWithModel(user, force: true)
        configureTwilioAndPusherServices()
    }
    
    func refreshAuthData(_ authData: AuthData) throws {
        
        // save
        let data = SecureCoder.dataWithJsonConvertible(authData)
        try keychain.set(data, key: authDataKey)
        
        // auth
        self.authData = authData
        APIManager.authData = authData
        
        if let user = self.user {
            updateTokenWithAuthData(authData, user: user)
        }
        
        configureTwilioAndPusherServices()
    }
    
    
    func switchToPage(_ page: DetailedPageProfile) {
        guard case .some(.logged(let user)) = loginState, let authData = authData, user.type == .User else {
            fatalError("User must be logged in to switch to page")
        }
        precondition(page.type == .Page)
        APIManager.setAuthToken(authData.apiToken, expiresAt: authData.expiresAt(), pageId: page.id)
        APIManager.authData = authData
        loginSubject.onNext(authData)
        loginState = .page(user: user, page: page)
        checkTwilioConnection()
        checkPusherConnection()
        checkPaperTrailLogger()
        facebookManager.logout()
    }
    
    func switchToUser() {
        guard case .some(.page(let user , _)) = loginState, let authData = authData else {
            fatalError("User must use app as page to switch back to user")
        }
        APIManager.setAuthToken(authData.apiToken, expiresAt: authData.expiresAt(), pageId: nil)
        loginSubject.onNext(authData)
        APIManager.authData = authData
        loginState = .logged(user: user)
        checkTwilioConnection()
        checkPusherConnection()
        checkPaperTrailLogger()
        facebookManager.logout()
    }
    
    func updateUserWithModel<T: User>(_ model: T, force: Bool = false) {
        if let model = model as? DetailedUserProfile, model.type == .User {
            switch (loginState, force) {
            case (.page(_, let page)?, _): loginState = .page(user: model, page: page)
            case (.logged(_)?, _), (.none, _), (_, true): loginState = .logged(user: model)
            default: break
            }
        }
        else if let model = model as? DetailedPageProfile, let admin = model.admin, model.type == .Page {
            switch (loginState, force) {
            case (.page(_)?, _), (.none, _), (_, true): loginState = .page(user: admin.value, page: model)
            default: break
            }
        }
        else if let model = model as? GuestUser {
            switch (loginState, force) {
            case (.guest(_)?, _), (.none, _), (_, true): loginState = .guest(user: model)
            default: break
            }
        }
    }
    
    fileprivate func updateTokenWithAuthData(_ authData: AuthData, user: User) {
        if let page = user as? DetailedPageProfile {
            APIManager.setAuthToken(authData.apiToken, expiresAt: authData.expiresAt(), pageId: page.id)
        } else {
            APIManager.setAuthToken(authData.apiToken, expiresAt: authData.expiresAt(), pageId: nil)
        }
    }
    
    func logout() throws {
        APIProfileService.nullifyPushTokens().subscribe(onNext: {}).addDisposableTo(disposeBag)
        try clearUserData()
        GIDSignIn.sharedInstance().signOut()
        facebookManager.logout()
    }
    
    func clearUserData() throws {
        try removeFilesFromUserDirecotry()
        try keychain.remove(self.authDataKey)
        loginState = nil
        authData = nil
        APIManager.authData = nil
        loginSubject.onNext(nil)
        APIManager.eraseAuthToken()
        pusherManager.disconnect()
        twilioManager.disconnect()
    }
}

extension Account {
    
    func locationString() -> String {
        if let city = user?.location.city, let state = user?.location.state, let country = user?.location.country {
            return "\(city), \(state), \(country)"
        }
        
        return NSLocalizedString("Unknown Location", comment: "Location String in Menu")
    }
    
    func fetchUserProfile() {
        guard case .logged(let user)? = loginState, isUserLoggedIn else { return }
        
        let observable: Observable<DetailedUserProfile> = APIProfileService.retrieveProfileWithUsername(user.username)
        observable.subscribe{ (event) in
            switch event {
            case .next(let profile):
                self.loginState = .logged(user: profile)
            case .error(let error): debugPrint(error)
            default: break
            }
            }.addDisposableTo(disposeBag)
    }
    
    func updateMainStats(_ stats: ProfileStats) {
        if case .page(let admin, let page)? = loginState {
            
            self.loginState = .page(user: admin, page: page.updatedProfileWithStats(stats))
            self.statsSubject.onNext(stats)
            return
        }
        
        guard case .logged(let user)? = loginState else { return }
        self.loginState = .logged(user: user.updatedProfileWithStats(stats))
        self.statsSubject.onNext(stats)
    }
    
    func updateAdminStats(_ stats: ProfileStats) {
        if case .page(let admin, let page)? = loginState {
            
            self.loginState = .page(user: admin.updatedProfileWithStats(stats), page: page)
            self.adminStatsSubject.onNext(stats)
            return
        }
    }
}

private extension Account {
    
    func updateApplicationBadgeNumberWithStats(_ stats: ProfileStats?) {
        UIApplication.shared.applicationIconBadgeNumber = ((stats?.unreadNotificationsCount) ?? 0) + ((stats?.unreadConversationCount) ?? 0)
    }
    
    func configureTwilioAndPusherServices() {
        
        switch loginState {
        case .some(.logged(_)):
            guard let authData = authData else { assertionFailure(); return; }
            pusherManager.setAuthorizationToken(authData.apiToken)
            _ = twilioManager
        case .some(.page(_, _)):
            guard let authData = authData else { assertionFailure(); return; }
            pusherManager.setAuthorizationToken(authData.apiToken)
            _ = twilioManager
        default:
            pusherManager.disconnect()
        }
    }
    
    func checkPaperTrailLogger() {
        if let paperTrailLogger = RMPaperTrailLogger.sharedInstance() {
            paperTrailLogger.programName = self.user?.id ?? "guest"
        }
    }
    
    func checkTwilioConnection() {
        
        guard self.user?.id != nil else {
            return
        }
        
        twilioManager.checkIfNeedsToReconnectForNewId()
    }
    
    func checkPusherConnection() {
        if case .page(_, let page)? = loginState {
            pusherManager.subscribeToPageMainChannel(page)
        } else {
            pusherManager.unsubscribePages()
        }
    }
    
    func removeFilesFromUserDirecotry() throws {
        guard FileManager.default.fileExists(atPath: userDirectory) else { return }
        let paths = try FileManager.default.contentsOfDirectory(atPath: userDirectory)
        for p in paths {
            let fullPath = URL(fileURLWithPath: userDirectory).appendingPathComponent(p).path
            try FileManager.default.removeItem(atPath: fullPath)
        }
    }
    
    func updateAPNSIfNeeded() {
        
        guard let user = self.user, let apnsToken = self.apnsToken, apnsToken != user.pushTokens?.apns && !updatingAPNS else { return }
        
        if case .page(let admin, _)? = loginState {
            if admin.pushTokens?.apns == self.apnsToken {
                return
            }
        }
        
        updatingAPNS = true
        
        let params = APNParams(tokens: PushTokens(apns: apnsToken, gcm: nil))
        
        if case .guest(let guest)? = loginState {
            let observable: Observable<GuestUser> = APIProfileService.updateAPNsWithUsername(guest.username, withParams: params)
            observable
                .subscribe{ (event) in
                    self.updatingAPNS = false
                    switch event {
                    case .next(let profile): self.updateUserWithModel(profile)
                    default: break
                    }
                }
                .addDisposableTo(disposeBag)
            
        }
        else if case .logged(let user)? = loginState {
            let observable: Observable<DetailedUserProfile> = APIProfileService.updateAPNsWithUsername(user.username, withParams: params)
            observable
                .subscribe{ (event) in
                    self.updatingAPNS = false
                    switch event {
                    case .next(let profile): self.updateUserWithModel(profile)
                    default: break
                    }
                }
                .addDisposableTo(disposeBag)
        } else if case .page(_, let page)? = loginState {
            let observable: Observable<DetailedPageProfile> = APIProfileService.updateAPNsWithUsername(page.username, withParams: params)
            observable
                .subscribe{ (event) in
                    self.updatingAPNS = false
                    switch event {
                    case .next(let profile): self.updateUserWithModel(profile)
                    default: break
                    }
                }
                .addDisposableTo(disposeBag)
        }
    }
    
    func createUserDirectory() -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let userDirecotryPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("user").path
        if !FileManager.default.fileExists(atPath: userDirecotryPath) {
            try! FileManager.default.createDirectory(atPath: userDirecotryPath, withIntermediateDirectories: false, attributes: nil)
        }
        return userDirecotryPath
    }
}
