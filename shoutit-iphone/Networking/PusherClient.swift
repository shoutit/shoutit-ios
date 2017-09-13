//
//  PusherClient.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import JSONCodable
import Reachability
import ShoutitKit

final class PusherClient : NSObject {
    
    #if STAGING
    private let pusherAppKey = "7bee1e468fabb6287fc5"
    #elseif LOCAL
    private let pusherAppKey = "d6a98f27e49289344791"
    #else
    fileprivate let pusherAppKey = "86d676926d4afda44089"
    #endif
    fileprivate let pusherURL = APIManager.baseURL + "/pusher/auth"
    
    fileprivate unowned var account: Account
    fileprivate var pusherInstance: PTPusher?
    fileprivate var reachability: Reachability!
    
    fileprivate var authToken : String?
    fileprivate var mainChannelIdentifier: String?
    fileprivate var mainPageChannelIdentifier: String?
    fileprivate var subscribedChannels : [String] = [] {
        didSet {
            print(subscribedChannels)
        }
    }
    fileprivate var keepDisconnected = false
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    var mainChannelSubject = PublishSubject<PTPusherEvent>()
    var subscribedPage : DetailedPageProfile?
    
    init(account: Account) {
        self.account = account
        super.init()
        
        pusherInstance = PTPusher(key: pusherAppKey, delegate: self)
        pusherInstance?.authorizationURL = URL(string: pusherURL)
        
        do {
            reachability = try Reachability()
            try reachability.startNotifier()
        } catch let error { print(error) }
        
        
        
        NotificationCenter.default
          .rx.notification(ReachabilityChangedNotification)
          .asObservable()
          .subscribe(onNext: { (notification) in
            if APIManager.isNetworkReachable() == false {
                return
            }
                    
            if self.pusherInstance?.connection.isConnected == false {
                self.tryToConnect()
            }
          }).addDisposableTo(disposeBag)
    }
    
    func setAuthorizationToken(_ token: String) {
        authToken = token
        tryToConnect()
    }
    
    func tryToConnect() {
        
        var userLoggedIn = false
        
        if case .logged(_)? = account.loginState {
            userLoggedIn = true
        }
        
        if case .page(_,_)? = account.loginState {
            userLoggedIn = true
        }
        
        if !userLoggedIn {
            disconnect()
        }
        
        keepDisconnected = false
        
        pusherInstance = PTPusher(key: pusherAppKey, delegate: self)
        pusherInstance?.authorizationURL = URL(string: pusherURL)
        
        // Connect only when user is logged
        if userLoggedIn {
            pusherInstance?.connect()
        }
    }
    
    func disconnect() {
        
        guard let pusher = pusherInstance else { return }
        
        if let channelName = self.mainChannelIdentifier, let ch = pusher.channelNamed(channelName) {
            ch.unsubscribe()
        }
        
        for channelName in self.subscribedChannels {
            if let ch = pusher.channelNamed(channelName) {
                ch.unsubscribe()
            }
        }
        
        pusher.disconnect()
    }
    
    fileprivate func reconnect() {
        if keepDisconnected {
            return
        }
        
        pusherInstance?.disconnect()
        tryToConnect()
    }
    
    fileprivate func subscribeToMainChannel() {
        
        mainChannelObservable().subscribe(onNext: { (event) -> Void in
            self.mainChannelSubject.onNext(event)
            
            if event.eventType() == .StatsUpdate {
                
                
                if let stats : ProfileStats = event.object() {
                    
                    switch self.account.loginState {
                    case .some(.page):
                        self.account.updateAdminStats(stats)
                    case .some(.logged):
                        self.account.updateMainStats(stats)
                    default: break
                    }
                }
            }
            
            if self.subscribedPage != nil {
                return
            }
            
            if event.eventType() == .ProfileChange {
                switch self.account.loginState {
                case .some(.logged):
                    if let profile : DetailedUserProfile = event.object() {
                        self.account.updateUserWithModel(profile)
                    }
                case .some(.guest):
                    if let guest : GuestUser = event.object() {
                        self.account.updateUserWithModel(guest)
                    }
                default: break
                }
            }

            
        }).addDisposableTo(disposeBag)
    }
    
    func unsubscribePages() {
        
        guard let subscribedPage = self.subscribedPage else {
            return
        }
        
        unsubscribeFromPageMainChannel(subscribedPage)
        self.subscribedPage = nil
    }
    
    func subscribeToPageMainChannel(_ page: DetailedPageProfile) {
        mainPageChannelObservable(page).subscribe(onNext: { (event) -> Void in
            
            
            
            self.mainChannelSubject.onNext(event)
            
            if event.eventType() == .StatsUpdate {
                if let stats : ProfileStats = event.object() {
                    self.account.updateMainStats(stats)
                }
            }
            
            if event.eventType() == .ProfileChange {
                switch self.account.loginState {
                case .some(.logged):
                    if let profile : DetailedPageProfile = event.object() {
                        self.account.updateUserWithModel(profile)
                    }
                case .some(.guest):
                    if let guest : GuestUser = event.object() {
                        self.account.updateUserWithModel(guest)
                    }
                default: break
                }
            }
            
            
            }).addDisposableTo(disposeBag)
    }
    
    func unsubscribeFromPageMainChannel(_ page: DetailedPageProfile) {
        let channelName = "presence-v3-p-\(page.id)"

        self.mainPageChannelIdentifier = channelName
        
        if let ch = self.pusherInstance?.channelNamed(channelName) {
            ch.unsubscribe()
        }
    }
    
    func connectToMainChannels() {
        subscribeToMainChannel()
        
        if case .page(_,let page)? = account.loginState {
            subscribeToPageMainChannel(page)
        }
    }
}

extension PusherClient : PTPusherDelegate {
    
    
    // Connection Delegates
    
    func pusher(_ pusher: PTPusher!, connectionDidConnect connection: PTPusherConnection!) {
        // WARNING //
        
        // There is issue with Pusher Library everytime pusher did connect it calls this delegate method and after that it calls subscribeAll.
        // If we do our subscription immediately it is added to internal `channels` dictionary and in subscribeAll that causes duplicate subscription.
        // So we want to add small delay before subscribing to avoid this situation.
        
        let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.connectToMainChannels()
        }
        
    }
    
    func pusher(_ pusher: PTPusher!, willAuthorizeChannel channel: PTPusherChannel!, with request: NSMutableURLRequest!) {
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
    }
    
    // Subscriptions
    
    func pusher(_ pusher: PTPusher!, didSubscribeTo channel: PTPusherChannel!) {
      
    }
    
    @objc func pusher(_ pusher: PTPusher!, didUnsubscribeFrom channel: PTPusherChannel!) {
      
        self.subscribedChannels.removeElementIfExists(channel.name)
    }
    
    // Error handling
    
    func pusher(_ pusher: PTPusher!, didReceive errorEvent: PTPusherErrorEvent!) {
       
    }
    
    func pusher(_ pusher: PTPusher!, didFailToSubscribeTo channel: PTPusherChannel!, withError error: Error!) {
       
    }
    
    func pusher(_ pusher: PTPusher!, connection: PTPusherConnection!, didDisconnectWithError error: Error!, willAttemptReconnect: Bool) {
       
    
        if !keepDisconnected {
            reconnect()
        }
    }
    
    func pusher(_ pusher: PTPusher!, connection: PTPusherConnection!, failedWithError error: Error!) {
        
    }
}

extension PusherClient {
    
    fileprivate func mainChannelObservable() -> Observable<PTPusherEvent> {
        return Observable.create { (observer) -> Disposable in
            
            guard let channelName = self.generateMainChannelIdentifier() else {
                observer.onError(PusherError.wrongChannelName)
                return Disposables.create { }
            }
            
            let channel : PTPusherChannel
            self.mainChannelIdentifier = channelName
            
            if let ch = self.pusherInstance?.channelNamed(channelName) {
                channel = ch
            } else {
                guard let ch = self.pusherInstance?.subscribe(toChannelNamed: channelName) else {
                    return Disposables.create { }
                }
                
                self.subscribedChannels.append(channelName)
                
                channel = ch
            }
            
 
            
            channel.bind(toEventNamed: PusherEventType.NewMessage.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.StatsUpdate.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.ProfileChange.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.NewListen.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.NewNotification.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            
            return Disposables.create {
                channel.unsubscribe()
            }
     
        }
    }
    
    fileprivate func mainPageChannelObservable(_ page: DetailedPageProfile) -> Observable<PTPusherEvent> {
        return Observable.create { (observer) -> Disposable in
            
            let channelName = "presence-v3-p-\(page.id)"
            
            let channel : PTPusherChannel
            self.mainPageChannelIdentifier = channelName
            
            if let ch = self.pusherInstance?.channelNamed(channelName) {
                channel = ch
            } else {
                guard let ch = self.pusherInstance?.subscribe(toChannelNamed: channelName) else {
                    return Disposables.create { }
                }
                
                self.subscribedChannels.append(channelName)
                
                channel = ch
            }
            
            channel.bind(toEventNamed:PusherEventType.NewMessage.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.StatsUpdate.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.ProfileChange.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.NewListen.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.NewNotification.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            
            return Disposables.create {
                channel.unsubscribe()
            }
        }
    }
    
    func conversationMessagesObservable(_ conversation: Conversation) -> Observable<Message> {
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
    
    func conversationObservable(_ conversation: ConversationInterface) -> Observable<PTPusherEvent> {
        return Observable.create({ (observer) -> Disposable in

            let channel : PTPusherChannel
            
            if let ch = self.pusherInstance?.channelNamed(conversation.channelName()) {
                channel = ch
            } else {
                guard let ch = self.pusherInstance?.subscribe(toChannelNamed: conversation.channelName()) else {
                    assertionFailure()
                    return Disposables.create{}
                }
                
                self.subscribedChannels.append(conversation.channelName())
                
                channel = ch
            }
            
            
            let cancel = Disposables.create {
                channel.unsubscribe()
            }
            
            channel.bind(toEventNamed:PusherEventType.UserTyping.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.JoinedChat.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.LeftChat.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.NewMessage.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            channel.bind(toEventNamed:PusherEventType.ConversationUpdate.rawValue, handleWith: { (event) in
                guard let event = event else { return }
                observer.onNext(event)
            })
            
            return cancel
        })
    }
    
    fileprivate func generateMainChannelIdentifier() -> String? {
        if case .some(.page(let admin, _)) = account.loginState {
            return "presence-v3-p-\(admin.id)"
        }
        
        if let user = account.user {
            return "presence-v3-p-\(user.id)"
        }
        
        return nil
    }
    
    func sendTypingEventToConversation(_ conversation: ConversationInterface) {
        guard let user = account.user else {
            return
        }
    
        let eventName = PusherEventType.UserTyping.rawValue
        let data = user.basicEncodedProfile()
        let channelName = conversation.channelName()
        
        pusherInstance?.sendEventNamed(eventName, data: data, channel: channelName)
    }
}
