//
//  Twilio.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class Twilio: NSObject, TwilioAccessManagerDelegate, TwilioConversationsClientDelegate {
    static let sharedInstance = Twilio()
    
    private var authData: TwilioAuth? {
        didSet {
            createTwilioClient()
        }
    }
    
    private var connecting : Bool = false
    private var disposeBag = DisposeBag()
    private var userChangeBag = DisposeBag()
    
    var client: TwilioConversationsClient?
    var accessManager: TwilioAccessManager?
    
    override init() {
        super.init()
        
        retriveToken()
    }
    
    func retriveToken() {
        if connecting {
            return
        }
        
        connecting = true
        
        APIChatsService.twilioVideoAuth().subscribeOn(MainScheduler.instance).subscribe { [weak self] (event) in
            switch event {
            case .Next(let authData):
                self?.authData = authData
                self?.connecting = false
                self?.subsribeForUserChange()
            case .Error(let error):
                print(error)
                self?.connecting = false
                self?.subsribeForUserChange()
            default: break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func subsribeForUserChange() {
        // release previous subscripitons
        userChangeBag = DisposeBag()
        
        Account.sharedInstance.loginSubject.subscribeNext { [weak self] (loginchanged) in
            self?.client?.unlisten()
            self?.client = nil
            self?.accessManager = nil
            self?.connecting = false
            
            if Account.sharedInstance.loggedUser != nil {
                // fetch token with small delay to avoid disposing client
                self?.performSelector("retriveToken", withObject: ni    l, afterDelay: 2.0)
            }
            
        }.addDisposableTo(userChangeBag)
    }
    
    func createTwilioClient() {
        guard let authData = authData else {
            fatalError("Twilio cannot be initialized before requesting an access token from Shoutit API")
        }
        
        print(authData.token)
        
        self.accessManager = TwilioAccessManager(token:authData.token, delegate:self)
        self.client = TwilioConversationsClient(accessManager: self.accessManager!, delegate: self)
        self.client?.listen()
        
        
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
        
        self.client?.inviteToConversation(identity.identity, localMedia: media, handler: { (conversation, error) in
            handler(conversation, error)
        })
    }
    
    
}


// Conversations Client Delegate
extension Twilio {
    func conversationsClientDidStartListeningForInvites(conversationsClient: TwilioConversationsClient) {
        debugPrint("start listning")
    }
    
    func conversationsClient(conversationsClient: TwilioConversationsClient, inviteDidCancel invite: TWCIncomingInvite) {
        debugPrint("did cancel invite")
    }
    
    func conversationsClient(conversationsClient: TwilioConversationsClient, didReceiveInvite invite: TWCIncomingInvite) {
        let notification = NSNotification(name: Constants.Notification.IncomingCallNotification, object: invite, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func conversationsClientDidStopListeningForInvites(conversationsClient: TwilioConversationsClient, error: NSError?) {
        reconnect()
    }
    
    func conversationsClient(conversationsClient: TwilioConversationsClient, didFailToStartListeningWithError error: NSError) {
        if error.code == 100 {
            retriveToken()
        }
    }
    
    func reconnect() {
        self.client?.unlisten()
        self.client?.listen()
    }
}

// Access Manager
extension Twilio {
    func accessManagerTokenExpired(accessManager: TwilioAccessManager!) {
        retriveToken()
    }
    
    func accessManager(accessManager: TwilioAccessManager!, error: NSError!) {
        fatalError(error.localizedDescription)
    }
}