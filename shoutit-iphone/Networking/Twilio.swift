//
//  Twilio.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit
import TwilioCommon

final class Twilio: NSObject {
    
    // consts
    private struct TwilioErrorCode {
        static let ParticipantUnavailable = 106
    }
    
    // vars
    var authData: TwilioAuth? {
        didSet {
            createTwilioClient()
        }
    }
    private unowned var account: Account
    private var client: TwilioConversationsClient?
    private var accessManager: TwilioAccessManager?
    private var authenticatedId : String?
    
    // helpers vars
    private var connecting : Bool = false
    lazy private var retryScheduler: Twilio.RetryScheduler = {[unowned self] in
        return RetryScheduler() {
            self.connectIfNeeded()
        }
    }()
    var sentInvitations : [TWCOutgoingInvite] = []
    
    // RX
    private var disposeBag = DisposeBag()
    private var userChangeBag = DisposeBag?()
    
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
        switch account.loginState {
        case .Logged(_)?, .Page(_)?:
            retriveToken()
        default:
            disconnect()
        }
    }
    
    func reconnect() {
        disconnect()
        connectIfNeeded()
    }
    
    func disconnect() {
        self.authenticatedId = nil
        if client?.listening == true {
            self.client?.unlisten()
        }
        self.connecting = false
        self.retryScheduler.resetAttemptsCount()
    }
    
    func makeCallTo(profile: Profile, media: TWCLocalMedia) -> Observable<TWCConversation> {
        return APIChatsService.twilioVideoIdentity(profile.username)
            .flatMap { (identity) -> Observable<TWCConversation> in
                return self
                    .inviteWithTwilioIdentity(identity, media: media)
                    .retryWhen{ (errorObservable) -> Observable<Int> in
                        let rangeObservable = Observable.range(start: 0, count: 3)
                        return Observable.zip(rangeObservable, errorObservable, resultSelector: { (attempt, error) -> (Int, ErrorType) in
                            return (attempt, error)
                        }).flatMap({ (attempt, error) -> Observable<Int> in
                            if (error as NSError).code == TwilioErrorCode.ParticipantUnavailable && attempt < 2 {
                                if self.sentInvitations.count > 0 {
                                    let invitation = self.sentInvitations.removeLast()
                                    invitation.cancel()
                                }
                                return Observable.timer(10, scheduler: SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .UserInteractive))
                            } else {
                                return Observable.error(error)
                            }
                        })
                    }
                    .doOnError { (error) in
                        APIChatsService.twilioVideoCallWithParams(VideoCallParams(identity: identity.identity, missed: true))
                            .subscribe{ (event) in
                                switch event {
                                case .Next: print("Call missed")
                                case .Error(let error): print("Call missed \(error)")
                                default: break
                                }
                            }
                            .addDisposableTo(self.disposeBag)
                    }
        }
    }
    
    private func inviteWithTwilioIdentity(identity: TwilioIdentity, media: TWCLocalMedia) -> Observable<TWCConversation> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            let params = VideoCallParams(identity: identity.identity, missed: false)
            APIChatsService.twilioVideoCallWithParams(params).subscribe{}.addDisposableTo(self.disposeBag)
            let invite = self.client?.inviteToConversation(identity.identity, localMedia: media, handler: { (conversation, error) in
                if let conversation = conversation {
                    observer.onNext(conversation)
                    observer.onCompleted()
                } else if let error = error {
                    observer.onError(error)
                }
            })
            if let invite = invite {
                self.sentInvitations.append(invite)
            }
            
            return NopDisposable.instance
        }
    }
    
    func checkIfNeedsToReconnectForNewId() {
        if self.authenticatedId != account.user?.id {
            reconnect()
        }
    }
}

private extension Twilio {
    
    @objc private func retriveToken() {
        
        if connecting || retryScheduler.waitingForNextRetryAttempt {
            return
        }
        
        connecting = true
        
        self.authenticatedId = account.user?.id
        
        APIChatsService.twilioVideoAuth().subscribeOn(MainScheduler.instance).subscribe { [weak self] (event) in
            self?.connecting = false
            
            switch event {
            case .Next(let authData):
                self?.authData = authData
            case .Error(_):
                break
            default: break
            }
            }.addDisposableTo(disposeBag)
    }
    
    private func createTwilioClient() {
        guard let authData = authData else {
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
            .observeOn(MainScheduler.instance)
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
    }
    
    func conversationsClient(conversationsClient: TwilioConversationsClient, inviteDidCancel invite: TWCIncomingInvite) {
    }
    
    func conversationsClient(conversationsClient: TwilioConversationsClient, didReceiveInvite invite: TWCIncomingInvite) {
        let notification = NSNotification(name: Constants.Notification.IncomingCallNotification, object: invite, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func conversationsClientDidStopListeningForInvites(conversationsClient: TwilioConversationsClient, error: NSError?) {
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