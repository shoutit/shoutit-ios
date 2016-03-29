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
    private let disposeBag = DisposeBag()
    
    var client: TwilioConversationsClient?
    var accessManager: TwilioAccessManager?
    
    override init() {
        super.init()
        retriveToken()
    }
    
    func retriveToken() {
        APIChatsService.twilioVideoAuth().subscribe { [weak self] (event) in
            switch event {
            case .Next(let authData):
                self?.authData = authData
            case .Error(let error):
                print(error)
            default: break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func createTwilioClient() {
        guard let authData = authData else {
            fatalError("Twilio canno be initialized before requesting an access token from Shoutit API")
        }
        
        self.accessManager = TwilioAccessManager(token:authData.token, delegate:self);
        self.client = TwilioConversationsClient(accessManager: self.accessManager!, delegate: self);
        self.client?.listen();
    }
    
    func sendInvitationTo(profile: Profile, handler: (TWCConversation?, NSError?) -> Void) {
        self.client?.inviteToConversation(profile.username, handler: { (conversation, error) in
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
        debugPrint("did receive invite")
    }
    
    func conversationsClientDidStopListeningForInvites(conversationsClient: TwilioConversationsClient, error: NSError?) {
        fatalError(error?.localizedDescription ?? "stopped listning")
    }
    
    func conversationsClient(conversationsClient: TwilioConversationsClient, didFailToStartListeningWithError error: NSError) {
        fatalError(error.localizedDescription)
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