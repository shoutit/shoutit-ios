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
    
    static let sharedInstance = PusherClient()
    
    #if STAGING
    private let pusherAppKey = "7bee1e468fabb6287fc5"
    #elseif LOCAL
    private let pusherAppKey = "d6a98f27e49289344791"
    #else
    private let pusherAppKey = "86d676926d4afda44089"
    #endif
    
    private let pusherURL = APIManager.baseURL + "/pusher/auth"
    
    var pusherInstance: PTPusher?
    
    private let disposeBag = DisposeBag()
    
    var mainChannelSubject = PublishSubject<PTPusherEvent>()
    
    private var authToken : String?
    
    var keepDisconnected = false
    
    private var reachability: Reachability!
    
    private var mainChannelIdentifier: String?
    private var subscribedChannels : [String] = []
    
    override init() {
        super.init()
        
        pusherInstance = PTPusher(key: pusherAppKey, delegate: self)
        pusherInstance?.authorizationURL = NSURL(string: pusherURL)
        
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            debugPrint("Unable to create Reachability")
            return
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            debugPrint("Unable to start notifier")
        }
        
        
        NSNotificationCenter.defaultCenter().rx_notification(ReachabilityChangedNotification).asObservable().subscribeNext { (notification) in
            if APIManager.isNetworkReachable() == false {
                return
            }
            
            if self.pusherInstance?.connection.connected == false {
                self.connect()
            }

        }.addDisposableTo(disposeBag)
        
    }
    
    func setAuthorizationToken(token: String) {
        authToken = token
        connect()
    }
    
    func tryToConnect() {
        
        var userLoggedIn = false
        
        if case .Logged(_)? = Account.sharedInstance.userModel {
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
    
    private func connect() {
        
        keepDisconnected = false
        
        pusherInstance = PTPusher(key: pusherAppKey, delegate: self)
        pusherInstance?.authorizationURL = NSURL(string: pusherURL)
        
        // Connect only when user is logged
        pusherInstance?.connect()
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
                    Account.sharedInstance.updateStats(stats)
                }
            }
            
            if event.eventType() == .ProfileChange {
                switch Account.sharedInstance.userModel {
                case .Some(.Logged):
                    if let profile : DetailedProfile = event.object() {
                        Account.sharedInstance.updateUserWithModel(profile)
                    }
                case .Some(.Guest):
                    if let guest : GuestUser = event.object() {
                        Account.sharedInstance.updateUserWithModel(guest)
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
            
            channel.bindToEventNamed(PusherEventType.NewMessage.rawValue, handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            channel.bindToEventNamed(PusherEventType.StatsUpdate.rawValue, handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            channel.bindToEventNamed(PusherEventType.ProfileChange.rawValue, handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            channel.bindToEventNamed(PusherEventType.NewListen.rawValue, handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            return AnonymousDisposable {
                channel.unsubscribe()
            }
        }
    }
    
    func conversationMessagesObservable(conversation: Conversation) -> Observable<Message> {
        return mainChannelSubject.filter({ (event) -> Bool in
            return event.eventType() == .NewMessage
        })
        .flatMap({ (event) -> Observable<Message> in
            if let msg : Message = event.object() {
                if msg.conversationId == conversation.id {
                    return Observable.just(msg)
                }
            }
            return Observable.never()
        })
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
            
            channel.bindToEventNamed(PusherEventType.UserTyping.rawValue, handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            channel.bindToEventNamed(PusherEventType.JoinedChat.rawValue, handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            channel.bindToEventNamed(PusherEventType.LeftChat.rawValue, handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            channel.bindToEventNamed(PusherEventType.NewMessage.rawValue, handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            return cancel
            
        })
    }
    
    private func generateMainChannelIdentifier() -> String? {
        if let user = Account.sharedInstance.user {
            return "presence-v3-p-\(user.id)"
        }
        
        return nil
    }
    
    func sendTypingEventToConversation(conversation: Conversation) {
        guard let user = Account.sharedInstance.user else {
            return
        }
    
        let eventName = PusherEventType.UserTyping.rawValue
        let data = user.basicEncodedProfile()
        let channelName = conversation.channelName()
        
        pusherInstance?.sendEventNamed(eventName, data: data, channel: channelName)
    }
}