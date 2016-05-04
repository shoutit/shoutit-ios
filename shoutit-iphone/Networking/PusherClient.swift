//
//  PusherClient.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Pusher
import RxSwift
import Argo
import Ogra
import ReachabilitySwift

final class PusherClient : NSObject {
    
    #if STAGING
    private let pusherAppKey = "7bee1e468fabb6287fc5"
    #elseif LOCAL
    private let pusherAppKey = "d6a98f27e49289344791"
    #else
    private let pusherAppKey = "86d676926d4afda44089"
    #endif
    private let pusherURL = APIManager.baseURL + "/pusher/auth"
    
    private unowned var account: Account
    private var pusherInstance: PTPusher?
    private var reachability: Reachability!
    
    private var authToken : String?
    private var mainChannelIdentifier: String?
    private var subscribedChannels : [String] = []
    private var keepDisconnected = false
    
    // RX
    private let disposeBag = DisposeBag()
    var mainChannelSubject = PublishSubject<PTPusherEvent>()
    
    init(account: Account) {
        self.account = account
        super.init()
        
        pusherInstance = PTPusher(key: pusherAppKey, delegate: self)
        pusherInstance?.authorizationURL = NSURL(string: pusherURL)
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            try reachability.startNotifier()
        } catch let error { print(error) }
        
        
        
        NSNotificationCenter.defaultCenter()
          .rx_notification(ReachabilityChangedNotification)
          .asObservable()
          .subscribeNext { (notification) in
            if APIManager.isNetworkReachable() == false {
                return
            }
                    
            if self.pusherInstance?.connection.connected == false {
                self.tryToConnect()
            }
          }.addDisposableTo(disposeBag)
    }
    
    func setAuthorizationToken(token: String) {
        authToken = token
        tryToConnect()
    }
    
    func tryToConnect() {
        
        var userLoggedIn = false
        
        if case .Logged(_)? = account.userModel {
            userLoggedIn = true
        }
        
        if !userLoggedIn {
            disconnect()
        }
        
        keepDisconnected = false
        
        pusherInstance = PTPusher(key: pusherAppKey, delegate: self)
        pusherInstance?.authorizationURL = NSURL(string: pusherURL)
        
        // Connect only when user is logged
        if userLoggedIn {
            pusherInstance?.connect()
        }
    }
    
    func disconnect() {
        
        guard let pusher = pusherInstance else { return }
        
        if let channelName = self.mainChannelIdentifier, ch = pusher.channelNamed(channelName) {
            ch.unsubscribe()
        }
        
        for channelName in self.subscribedChannels {
            if let ch = pusher.channelNamed(channelName) {
                ch.unsubscribe()
            }
        }
        
        pusher.disconnect()
    }
    
    private func reconnect() {
        if keepDisconnected {
            return
        }
        
        pusherInstance?.disconnect()
        tryToConnect()
    }
    
    private func subscribeToMainChannel() {
        mainChannelObservable().subscribeNext { (event) -> Void in
        
            log.info("PUSHER: MAIN CHANNEL EVENT: \(event.name) --- \n ---- \(event.data)")
            
            self.mainChannelSubject.onNext(event)
            
            if event.eventType() == .StatsUpdate {
                if let stats : ProfileStats = event.object() {
                    self.account.updateStats(stats)
                }
            }
            
            if event.eventType() == .ProfileChange {
                switch self.account.userModel {
                case .Some(.Logged):
                    if let profile : DetailedProfile = event.object() {
                        self.account.updateUserWithModel(profile)
                    }
                case .Some(.Guest):
                    if let guest : GuestUser = event.object() {
                        self.account.updateUserWithModel(guest)
                    }
                default: break
                }
            }

            
        }.addDisposableTo(disposeBag)
    }
}

extension PusherClient : PTPusherDelegate {
    
    
    // Connection Delegates
    
    func pusher(pusher: PTPusher!, connectionDidConnect connection: PTPusherConnection!) {
        log.verbose("PUSHER: CONNECTED")
        subscribeToMainChannel()
    }
    
    func pusher(pusher: PTPusher!, willAuthorizeChannel channel: PTPusherChannel!, withRequest request: NSMutableURLRequest!) {
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
    }
    
    // Subscriptions
    
    func pusher(pusher: PTPusher!, didSubscribeToChannel channel: PTPusherChannel!) {
        log.info("PUSHER: didSubscribeToChannel: \(channel.name)")
    }
    
    func pusher(pusher: PTPusher!, didUnsubscribeFromChannel channel: PTPusherChannel!) {
        log.info("PUSHER: didUnsubscribeFromChannel: \(channel.name)")
    }
    
    // Error handling
    
    func pusher(pusher: PTPusher!, didReceiveErrorEvent errorEvent: PTPusherErrorEvent!) {
        log.error("PUSHER: DID RECEIVE ERROR EVENT: | \(errorEvent.data["message"])")
    }
    
    func pusher(pusher: PTPusher!, didFailToSubscribeToChannel channel: PTPusherChannel!, withError error: NSError!) {
        log.error("PUSHER: DID FAIL TO SUBSCRIBE TO CHANNEL: \(channel) --- \n ---- \(error)")
    }
    
    func pusher(pusher: PTPusher!, connection: PTPusherConnection!, didDisconnectWithError error: NSError!, willAttemptReconnect: Bool) {
        log.error("PUSHER: DID DISCONNECT WITH ERROR: \(error)")
    
        if !keepDisconnected {
            reconnect()
        }
    }
    
    func pusher(pusher: PTPusher!, connection: PTPusherConnection!, failedWithError error: NSError!) {
        log.error("PUSHER: FAILED WITH ERROR: \(error)")
    }
}

extension PusherClient {
    
    private func mainChannelObservable() -> Observable<PTPusherEvent> {
        return Observable.create { (observer) -> Disposable in
            
            guard let channelName = self.generateMainChannelIdentifier() else {
                observer.onError(PusherError.WrongChannelName)
                return AnonymousDisposable { }
            }
            
            let channel : PTPusherChannel
            self.mainChannelIdentifier = channelName
            
            if let ch = self.pusherInstance?.channelNamed(channelName) {
                channel = ch
            } else {
                guard let ch = self.pusherInstance?.subscribeToChannelNamed(channelName) else {
                    return AnonymousDisposable { }
                }
                
                self.subscribedChannels.append(channelName)
                
                channel = ch
            }
            
            channel.bindToEventNamed(PusherEventType.NewMessage.rawValue) {observer.onNext($0)}
            channel.bindToEventNamed(PusherEventType.StatsUpdate.rawValue) {observer.onNext($0)}
            channel.bindToEventNamed(PusherEventType.ProfileChange.rawValue) {observer.onNext($0)}
            channel.bindToEventNamed(PusherEventType.NewListen.rawValue) {observer.onNext($0)}
            
            return AnonymousDisposable {
                channel.unsubscribe()
            }
        }
    }
    
    func conversationMessagesObservable(conversation: Conversation) -> Observable<Message> {
        return mainChannelSubject
            .filter{ (event) -> Bool in
                return event.eventType() == .NewMessage
            }
            .flatMap{ (event) -> Observable<Message> in
                if let msg : Message = event.object() {
                    if msg.conversationId == conversation.id {
                        return Observable.just(msg)
                    }
                }
                return Observable.never()
            }
    }
    
    func conversationObservable(conversation: Conversation) -> Observable<PTPusherEvent> {
        return Observable.create({ (observer) -> Disposable in

            let channel : PTPusherChannel
            
            if let ch = self.pusherInstance?.channelNamed(conversation.channelName()) {
                channel = ch
            } else {
                guard let ch = self.pusherInstance?.subscribeToChannelNamed(conversation.channelName()) else {
                    assertionFailure()
                    return AnonymousDisposable{}
                }
                
                self.subscribedChannels.append(conversation.channelName())
                
                channel = ch
            }
            
            
            let cancel = AnonymousDisposable {
                channel.unsubscribe()
            }
            
            channel.bindToEventNamed(PusherEventType.UserTyping.rawValue) {observer.onNext($0)}
            channel.bindToEventNamed(PusherEventType.JoinedChat.rawValue) {observer.onNext($0)}
            channel.bindToEventNamed(PusherEventType.LeftChat.rawValue) {observer.onNext($0)}
            channel.bindToEventNamed(PusherEventType.NewMessage.rawValue) {observer.onNext($0)}
            
            return cancel
            
        })
    }
    
    private func generateMainChannelIdentifier() -> String? {
        if let user = account.user {
            return "presence-v3-p-\(user.id)"
        }
        
        return nil
    }
    
    func sendTypingEventToConversation(conversation: Conversation) {
        guard let user = account.user else {
            return
        }
    
        let eventName = PusherEventType.UserTyping.rawValue
        let data = user.basicEncodedProfile()
        let channelName = conversation.channelName()
        
        pusherInstance?.sendEventNamed(eventName, data: data, channel: channelName)
    }
}