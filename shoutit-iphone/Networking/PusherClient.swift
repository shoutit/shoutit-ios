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
    
    private let pusherAppKey = "7bee1e468fabb6287fc5"
    private let pusherURL = APIManager.baseURL + "/pusher/auth"
    
    var pusherInstance: PTPusher!
    
    private let disposeBag = DisposeBag()
    
    private var authToken : String?
    
    var keepDisconnected = false
    
    private var reachability: Reachability!
    
    override init() {
        super.init()
        
        pusherInstance = PTPusher(key: pusherAppKey, delegate: self)
        pusherInstance.authorizationURL = NSURL(string: pusherURL)
        
        
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
            
            guard let pusher = self.pusherInstance else {
                return
            }
            
            if pusher.connection.connected == false {
                self.connect()
            }

        }.addDisposableTo(disposeBag)
        
    }
    
    func reconnect() {
        if keepDisconnected {
            return
        }
        
        pusherInstance.disconnect()
        pusherInstance = PTPusher(key: pusherAppKey, delegate: self)
        pusherInstance.authorizationURL = NSURL(string: pusherURL)
        connect()
    }
    
    func connect() {
        
        keepDisconnected = false
        
        pusherInstance = PTPusher(key: pusherAppKey, delegate: self)
        pusherInstance.authorizationURL = NSURL(string: pusherURL)
        
        pusherInstance.connect()
    }
    
    func disconnect() {
        keepDisconnected = true
        pusherInstance.disconnect()
        
        pusherInstance = nil
    }
    
    func setAuthorizationToken(token: String?) {
        if let token = token {
            authToken = token
            tryToConnect()
        } else {
            disconnect()
        }
    }
    
    func tryToConnect() {
        connect()
    }
    
    func subscribeToMainChannel() {
        mainChannelObservable().subscribeNext { (event) -> Void in
            print("RECEIVED: \(event.name)")
            print(event.data)
            
            if event.eventType() == .NewListen || event.eventType() == .NewMessage {
                
            }
            
            if event.eventType() == .StatsUpdate {
                if let stats : ProfileStats = event.object() {
                    Account.sharedInstance.updateStats(stats)
                }
            }
            
            if event.eventType() == .ProfileChange {
                if let profile : DetailedProfile = event.object() {
                    Account.sharedInstance.loggedUser = profile
                }
            }

            
        }.addDisposableTo(disposeBag)
    }
    
    func handleMessage(message: Message) {
        
    }
}

extension PusherClient : PTPusherDelegate {
    
    
    // Connection Delegates
    
    func pusher(pusher: PTPusher!, connectionDidConnect connection: PTPusherConnection!) {
        debugPrint("PUSHER CONNECTED")
        subscribeToMainChannel()
        
    }
    
    func pusher(pusher: PTPusher!, willAuthorizeChannel channel: PTPusherChannel!, withRequest request: NSMutableURLRequest!) {
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
    }
    
    // Subscriptions
    
    func pusher(pusher: PTPusher!, didSubscribeToChannel channel: PTPusherChannel!) {
        
    }
    
    func pusher(pusher: PTPusher!, didUnsubscribeFromChannel channel: PTPusherChannel!) {
        
    }
    
    // Error handling
    
    func pusher(pusher: PTPusher!, didReceiveErrorEvent errorEvent: PTPusherErrorEvent!) {
        debugPrint("PUSHER DID RECEIVE ERROR EVENT")
        print(errorEvent)
        print(errorEvent.data)
    }
    
    func pusher(pusher: PTPusher!, didFailToSubscribeToChannel channel: PTPusherChannel!, withError error: NSError!) {
        print(error ?? "nilError")
    }
    
    func pusher(pusher: PTPusher!, connection: PTPusherConnection!, didDisconnectWithError error: NSError!, willAttemptReconnect: Bool) {
        debugPrint("PUSHER DID DISCONNECT WITH ERROR")
        print(error ?? "nilError")
        if !keepDisconnected {
            reconnect()
        }
    }
    
    func pusher(pusher: PTPusher!, connection: PTPusherConnection!, failedWithError error: NSError!) {
        debugPrint("FAILED WITH ERROR")
        print(error ?? "nilError")
    }
}

extension PusherClient {
    func mainChannelObservable() -> Observable<PTPusherEvent> {
        return Observable.create { (observer) -> Disposable in
            let cancel = AnonymousDisposable {
                
            }
            
            guard let channelName = self.mainChannelIdentifier() else {
                observer.onError(PusherError.WrongChannelName)
                return cancel
            }
            
            let channel = self.pusherInstance.subscribeToChannelNamed(channelName)
            
            
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
            
            return cancel
        }
    }
    
    func conversationMessagesObservable(conversation: Conversation) -> Observable<Message> {
        return mainChannelObservable().filter({ (event) -> Bool in
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
            let channel = self.pusherInstance.subscribeToChannelNamed(conversation.channelName())
            
            let cancel = AnonymousDisposable {
                channel.removeAllBindings()
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
            
            return cancel
            
        })
    }
    
    func mainChannelIdentifier() -> String? {
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
        
        pusherInstance.sendEventNamed(eventName, data: data, channel: channelName)
    }
}