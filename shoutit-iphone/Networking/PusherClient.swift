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

final class PusherClient : NSObject {
    
    static let sharedInstance = PusherClient()
    
    private let pusherAppKey = "86d676926d4afda44089"
    private let pusherURL = APIManager.baseURL + "/pusher/auth"
    
    var pusherInstance: PTPusher!
    
    private let disposeBag = DisposeBag()
    
    private var authToken : String?
    
    override init() {
        super.init()
        
        pusherInstance = PTPusher(key: pusherAppKey, delegate: self)
        pusherInstance.authorizationURL = NSURL(string: pusherURL)
    }
    
    func connect() {
        pusherInstance.connect()
    }
    
    func disconnect() {
        pusherInstance.disconnect()
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
        if pusherInstance.connection.connected {
            debugPrint("Pusher Already connected")
            return
        }
        
        connect()
    }
    
    func subscribeToMainChannel() {
        mainChannelObservable().retry(10).subscribeNext { (event) -> Void in
            print("RECEIVED: \(event.name)")
            print(event.data)
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
        print(error)
    }
    
    func pusher(pusher: PTPusher!, connection: PTPusherConnection!, didDisconnectWithError error: NSError!, willAttemptReconnect: Bool) {
        debugPrint("PUSHER DID DISCONNECT WITH ERROR")
        print(error)
    }
    
    func pusher(pusher: PTPusher!, connection: PTPusherConnection!, failedWithError error: NSError!) {
        debugPrint("FAILED WITH ERROR")
        print(error)
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
            
            channel.bindToEventNamed("new_message", handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            channel.bindToEventNamed("new_listen", handleWithBlock: { (event) -> Void in
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
            let cancel = AnonymousDisposable {
                
            }
            
            let channel = self.pusherInstance.subscribeToChannelNamed(conversation.channelName())
            
            channel.bindToEventNamed("user_is_typing", handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            channel.bindToEventNamed("joined_chat", handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            channel.bindToEventNamed("left_chat", handleWithBlock: { (event) -> Void in
                observer.onNext(event)
            })
            
            return cancel
            
        })
    }
    
    func mainChannelIdentifier() -> String? {
        if let user = Account.sharedInstance.user {
            return "presence-u-\(user.id)"
        }
        
        return nil
    }
    
    func sendTypingEventToConversation(conversation: Conversation) {
        guard let user = Account.sharedInstance.user else {
            return
        }
    
        let eventName = "client-" + PusherEventType.UserTyping.rawValue
        let data = user.basicEncodedProfile()
        let channelName = conversation.channelName()
        
        pusherInstance.sendEventNamed(eventName, data: data, channel: channelName)
    }
}