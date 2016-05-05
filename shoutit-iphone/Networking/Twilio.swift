//
//  Twilio.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift


final class Twilio: NSObject {
    
    private var authData: TwilioAuth? {
        didSet {
            log.info("TWILIO: TOKEN RETRIVED")
            createTwilioClient()
        }
    }
    
    private unowned var account: Account
    private var client: TwilioConversationsClient?
    private var accessManager: TwilioAccessManager?
    
    // helpers vars
    private var connecting : Bool = false
    lazy private var retryScheduler: Twilio.RetryScheduler = {[unowned self] in
        return RetryScheduler() {
            self.connectIfNeeded()
        }
    }()
    
    // RX
    private var disposeBag = DisposeBag()
    private var userChangeBag = DisposeBag?()
    
    var sentInvitations : [TWCOutgoingInvite] = []
    
    // MARK: - Lifecycle
    
    init(account: Account) {
        self.account = account
        super.init()
        
        connectIfNeeded()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(connectIfNeeded), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(disconnect), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        subsribeForUserChange()
    }
    
    
    deinit {
        userChangeBag = nil
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    // MARK: - Public
    
    func connectIfNeeded() {
        if case .Logged(_)? = account.userModel {
            retriveToken()
        } else {
            disconnect()
        }
    }
    
    func disconnect() {
        if client?.listening == true {
            self.client?.unlisten()
        }
        self.connecting = false
        self.retryScheduler.resetAttemptsCount()
    }
    
    func sendInvitationTo(profile: Profile, media: TWCLocalMedia, handler: (TWCConversation?, NSError?) -> Void) {
        
        APIChatsService.twilioVideoIdentity(profile.username)
        .subscribe(onNext: { [weak self] (identity) in
            self?.sendInvitationToIdentity(identity, media: media, handler: handler)
        }, onError: { [weak self] (error) in
            self?.sendInvitationToIdentity(nil, media: media, handler: handler)
        }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    func sendInvitationToIdentity(identity: TwilioIdentity?,media: TWCLocalMedia, handler: (TWCConversation?, NSError?) -> Void) {
        guard let identity = identity else {
            let error = NSError(domain: "com.shoutit.internal", code: 403, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("You are not able to call this user", comment: "")])
            handler(nil, error)
            return
        }
        
        let invite = self.client?.inviteToConversation(identity.identity, localMedia: media, handler: { (conversation, error) in
            defer { handler(conversation, error) }
            guard let _ = error else { return }
            
            APIChatsService.twilioMissedCallWithParams(MissedCallParams(identity: identity.identity))
                .subscribe{ (event) in
                    switch event {
                    case .Next: print("Call missed")
                    case .Error(let error): print("Call missed \(error)")
                    default: break
                    }
                }
                .addDisposableTo(self.disposeBag)
        })
        
        if let invite = invite {
            self.sentInvitations.append(invite)
        }
    }
}

private extension Twilio {
    
    @objc private func retriveToken() {
        
        if connecting || retryScheduler.waitingForNextRetryAttempt {
            return
        }
        
        connecting = true
        
        log.verbose("TWILIO: TRYING TO RETRIVE TOKEN")
        
        APIChatsService.twilioVideoAuth().subscribeOn(MainScheduler.instance).subscribe { [weak self] (event) in
            self?.connecting = false
            
            switch event {
            case .Next(let authData):
                self?.authData = authData
            case .Error(let error):
                log.error(error)
            default: break
            }
            }.addDisposableTo(disposeBag)
    }
    
    private func createTwilioClient() {
        guard let authData = authData else {
            log.error("Twilio cannot be initialized before requesting an access token from Shoutit API")
            return
        }
        
        self.accessManager = TwilioAccessManager(token:authData.token, delegate:self)
        self.client = TwilioConversationsClient(accessManager: self.accessManager!, delegate: self)
        self.client?.listen()
    }
    
    private func subsribeForUserChange() {
        // release previous subscripitons
        let bag = DisposeBag()
        
        userChangeBag = bag
        
        //  fetch token with small delay to avoid disposing client
        account.loginSubject
            .subscribeNext { [weak self] (loginchanged) in
                guard let `self` = self else { return }
                self.performSelector(#selector(self.connectIfNeeded), withObject: nil, afterDelay: 2.0)
            }
            .addDisposableTo(bag)
    }
}

private extension Twilio {
    
    private class RetryScheduler {
        
        private(set) var waitingForNextRetryAttempt = false
        let callback: Void -> Void
        private let numberOfRetries = 3
        private let retriesInterval: NSTimeInterval = 30
        
        private var numberOfRetriesLeft = 3
        private var retryTimer: NSTimer?
        
        init(callback: (Void -> Void)) {
            self.callback = callback
        }
        
        func retry() {
            guard numberOfRetriesLeft > 0 && !waitingForNextRetryAttempt else { return }
            defer { numberOfRetriesLeft -= 1 }
            
            if numberOfRetriesLeft == numberOfRetries {
                callback()
            }
            scheduleRetry()
        }
        
        func resetAttemptsCount() {
            numberOfRetriesLeft = numberOfRetries
            invalidateRetryTimer()
        }
        
        private func scheduleRetry() {
            guard retryTimer == nil else { return }
            waitingForNextRetryAttempt = true
            retryTimer = NSTimer.scheduledTimerWithTimeInterval(retriesInterval, target: self, selector: #selector(handleRetryTimerDidFinishCountdown), userInfo: nil, repeats: false)
        }
        
        @objc func handleRetryTimerDidFinishCountdown() {
            invalidateRetryTimer()
            callback()
        }
        
        private func invalidateRetryTimer() {
            waitingForNextRetryAttempt = false
            retryTimer?.invalidate()
            retryTimer = nil
        }
    }
}

// Conversations Client Delegate
extension Twilio: TwilioConversationsClientDelegate {
    
    func conversationsClientDidStartListeningForInvites(conversationsClient: TwilioConversationsClient) {
        retryScheduler.resetAttemptsCount()
        log.info("TWILIO: DID START LISTNING FOR INVITES")
    }
    
    func conversationsClient(conversationsClient: TwilioConversationsClient, inviteDidCancel invite: TWCIncomingInvite) {
        log.info("TWILIO: DID CANCEL INVITE")
    }
    
    func conversationsClient(conversationsClient: TwilioConversationsClient, didReceiveInvite invite: TWCIncomingInvite) {
        log.info("TWILIO: DID RECEIVE INVITE")
        
        let notification = NSNotification(name: Constants.Notification.IncomingCallNotification, object: invite, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func conversationsClientDidStopListeningForInvites(conversationsClient: TwilioConversationsClient, error: NSError?) {
        log.warning("TWILIO: DID STOP LISTENING FOR INVITES \(error)")
    }
    
    func conversationsClient(conversationsClient: TwilioConversationsClient, didFailToStartListeningWithError error: NSError) {
        if error.code == 100 {
            retryScheduler.retry()
        }
    }
}

// Access Manager
extension Twilio: TwilioAccessManagerDelegate {
    
    func accessManagerTokenExpired(accessManager: TwilioAccessManager!) {
        retryScheduler.retry()
    }
    
    func accessManager(accessManager: TwilioAccessManager!, error: NSError!) {
        fatalError(error.localizedDescription)
    }
}