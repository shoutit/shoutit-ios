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
    
    // RX
    private var disposeBag = DisposeBag()
    private var userChangeBag = DisposeBag?()
    
    var sentInvitations : [TWCOutgoingInvite] = []
    
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
    
    func connectIfNeeded() {
        if case .Logged(_)? = account.userModel {
            retriveToken()
        } else {
            disconnect()
        }
    }
    
    @objc private func retriveToken() {
        if connecting {
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
    
    private func subsribeForUserChange() {
        // release previous subscripitons
        let bag = DisposeBag()
        
        userChangeBag = bag
        
        //  fetch token with small delay to avoid disposing client
        account.loginSubject.subscribeNext { [weak self] (loginchanged) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.performSelector(#selector(strongSelf.connectIfNeeded), withObject: nil, afterDelay: 2.0)
        }.addDisposableTo(bag)
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
    
    func disconnect() {
        self.client?.unlisten()
        self.connecting = false
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
            if let _ = error {
                APIChatsService.twilioMissedCallWithParams(MissedCallParams(identity: identity.identity)).subscribe({ (event) in
                    switch event {
                    case .Next: print("Call missed")
                    case .Error(let error): print("Call missed \(error)")
                    default: break
                    }
                }).addDisposableTo(self.disposeBag)
                return
            }
            
            handler(conversation, error)
        })
        
        if let invite = invite {
            self.sentInvitations.append(invite)
        }
    }
    
    
}


// Conversations Client Delegate
extension Twilio {
    func conversationsClientDidStartListeningForInvites(conversationsClient: TwilioConversationsClient) {
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
            connectIfNeeded()
        }
    }
}

// Access Manager
extension Twilio {
    func accessManagerTokenExpired(accessManager: TwilioAccessManager!) {
        connectIfNeeded()
    }
    
    func accessManager(accessManager: TwilioAccessManager!, error: NSError!) {
        fatalError(error.localizedDescription)
    }
}