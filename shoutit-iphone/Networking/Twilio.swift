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
    fileprivate struct TwilioErrorCode {
        static let ParticipantUnavailable = 106
    }
    
    // vars
    var authData: TwilioAuth? {
        didSet {
            createTwilioClient()
        }
    }
    fileprivate unowned var account: Account
    fileprivate var client: TwilioConversationsClient?
    fileprivate var accessManager: TwilioAccessManager?
    fileprivate var authenticatedId : String?
    
    // helpers vars
    fileprivate var connecting : Bool = false
    lazy fileprivate var retryScheduler: Twilio.RetryScheduler = {[unowned self] in
        return RetryScheduler() {
            self.connectIfNeeded()
        }
    }()
    var sentInvitations : [TWCOutgoingInvite] = []
    
    // RX
    fileprivate var disposeBag = DisposeBag()
    fileprivate var userChangeBag: DisposeBag? = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(account: Account) {
        self.account = account
        super.init()
        
        connectIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectIfNeeded), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnect), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        subsribeForUserChange()
    }
    
    
    deinit {
        userChangeBag = nil
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // MARK: - Public
    
    func connectIfNeeded() {
        switch account.loginState {
        case .logged(_)?, .page(_)?:
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
    
    func makeCallTo(_ profile: Profile, media: TWCLocalMedia) -> Observable<TWCConversation> {
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
                                case .error(let error): print("Call missed \(error)")
                                default: break
                                }
                            }
                            .addDisposableTo(self.disposeBag)
                    }
        }
    }
    
    fileprivate func inviteWithTwilioIdentity(_ identity: TwilioIdentity, media: TWCLocalMedia) -> Observable<TWCConversation> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            let params = VideoCallParams(identity: identity.identity, missed: false)
            APIChatsService.twilioVideoCallWithParams(params).subscribe{}.addDisposableTo(self.disposeBag)
            let invite = self.client?.invite(toConversation: identity.identity, localMedia: media, handler: { (conversation, error) in
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
            
            return Disposables.create {}
        }
    }
    
    func checkIfNeedsToReconnectForNewId() {
        if self.authenticatedId != account.user?.id {
            reconnect()
        }
    }
}

private extension Twilio {
    
    @objc func retriveToken() {
        
        if connecting || retryScheduler.waitingForNextRetryAttempt {
            return
        }
        
        connecting = true
        
        self.authenticatedId = account.user?.id
        
        APIChatsService.twilioVideoAuth().subscribeOn(MainScheduler.instance).subscribe { [weak self] (event) in
            self?.connecting = false
            
            switch event {
            case .next(let authData):
                self?.authData = authData
            case .Error(_):
                break
            default: break
            }
            }.addDisposableTo(disposeBag)
    }
    
    func createTwilioClient() {
        guard let authData = authData else {
            return
        }
        
        self.accessManager = TwilioAccessManager(token:authData.token, delegate:self)
        self.client = TwilioConversationsClient(accessManager: self.accessManager!, delegate: self)
        self.client?.listen()
    }
    
    func subsribeForUserChange() {
        // release previous subscripitons
        let bag = DisposeBag()
        
        userChangeBag = bag
        
        //  fetch token with small delay to avoid disposing client
        account.loginSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (loginchanged) in
                guard let `self` = self else { return }
                self.perform(#selector(self.connectIfNeeded), with: nil, afterDelay: 2.0)
            })
            .addDisposableTo(bag)
    }
}

private extension Twilio {
    
    class RetryScheduler {
        
        fileprivate(set) var waitingForNextRetryAttempt = false
        let callback: (Void) -> Void
        fileprivate let numberOfRetries = 3
        fileprivate let retriesInterval: TimeInterval = 30
        
        fileprivate var numberOfRetriesLeft = 3
        fileprivate var retryTimer: Timer?
        
        init(callback: @escaping ((Void) -> Void)) {
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
        
        fileprivate func scheduleRetry() {
            guard retryTimer == nil else { return }
            waitingForNextRetryAttempt = true
            retryTimer = Timer.scheduledTimer(timeInterval: retriesInterval, target: self, selector: #selector(handleRetryTimerDidFinishCountdown), userInfo: nil, repeats: false)
        }
        
        @objc func handleRetryTimerDidFinishCountdown() {
            invalidateRetryTimer()
            callback()
        }
        
        fileprivate func invalidateRetryTimer() {
            waitingForNextRetryAttempt = false
            retryTimer?.invalidate()
            retryTimer = nil
        }
    }
}

// Conversations Client Delegate
extension Twilio: TwilioConversationsClientDelegate {
    
    func conversationsClientDidStartListening(forInvites conversationsClient: TwilioConversationsClient) {
        retryScheduler.resetAttemptsCount()
    }
    
    func conversationsClient(_ conversationsClient: TwilioConversationsClient, inviteDidCancel invite: TWCIncomingInvite) {
    }
    
    func conversationsClient(_ conversationsClient: TwilioConversationsClient, didReceive invite: TWCIncomingInvite) {
        let notification = Foundation.Notification(name: Constants.Notification.IncomingCallNotification, object: invite, userInfo: nil)
        NotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func conversationsClientDidStopListeningForInvites(_ conversationsClient: TwilioConversationsClient, error: NSError?) {
    }
    
    func conversationsClient(_ conversationsClient: TwilioConversationsClient, didFailToStartListeningWithError error: NSError) {
        if error.code == 100 {
            retryScheduler.retry()
        }
    }
}

// Access Manager
extension Twilio: TwilioAccessManagerDelegate {
    func accessManager(_ accessManager: TwilioAccessManager!, error: Error!) {
        fatalError(error.localizedDescription)
    }

    
    func accessManagerTokenExpired(_ accessManager: TwilioAccessManager!) {
        retryScheduler.retry()
    }
}
