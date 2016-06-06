//
//  VideoCallViewModel.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 06.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class VideoCallViewModel {
    
    enum State {
        case ReadyForCall
        case Calling
        case InCall
        case CallEnded
        case CallFailed
    }
    
    let callerProfile: Variable<Profile?>
    let conversation: Variable<TWCConversation?>
    let localMedia: TWCLocalMedia
    let state: Variable<State>
    let errorSubject: PublishSubject<ErrorType> = PublishSubject()
    private let disposeBag = DisposeBag()
    
    var callDurationTimer: NSTimer?
    
    init(callerProfile: Profile?) {
        self.callerProfile = Variable(callerProfile)
        self.conversation = Variable(nil)
        self.localMedia = TWCLocalMedia()
        self.state = Variable(.ReadyForCall)
    }
    
    init(conversation: TWCConversation, localMedia: TWCLocalMedia) {
        self.conversation = Variable(conversation)
        self.callerProfile = Variable(nil)
        self.localMedia = localMedia
        self.state = Variable(.Calling)
        if let identity = conversation.participants.first?.identity {
            fetchCallingProfileWithIdentity(identity)
        }
    }
    
    // MARK: - Actions
    
    func startCall() {
        
        guard let callingToProfile = callerProfile else {
            assertionFailure()
            endCall()
            return
        }
        
        state.value = .Calling
        
        Account.sharedInstance
            .twilioManager
            .makeCallTo(callingToProfile, media: localMedia).subscribe({[weak self] (event) in
                switch event {
                case .Error(let error):
                    self?.state.value = .CallFailed
                    self?.errorSubject.onNext(error)
                case .Next(let conversation):
                    self?.conversation = conversation
                default:
                    break
                }
                })
            .addDisposableTo(disposeBag)
    }
    
    func endCall() {
        
        conversation?.disconnect()
        
        let sentInvitations = Account.sharedInstance.twilioManager.sentInvitations
        for invite : TWCOutgoingInvite in sentInvitations {
            invite.cancel()
        }
        Account.sharedInstance.twilioManager.sentInvitations = []
        
        state = .CallEnded
    }
    
    // MARK: - Readable data
    
    func messageText() -> String? {
        switch self.state {
        case .ReadyForCall:
            if let username = callingToProfile?.username {
                return String.localizedStringWithFormat(NSLocalizedString("Video call with %@", comment: "Video call status message"), username)
            }
        case .Calling:
            if let participantIdentity = conversation?.participants.first?.identity {
                return String.localizedStringWithFormat(NSLocalizedString("Connecting with %@...", comment: "Video call status message"), participantIdentity)
            } else {
                return NSLocalizedString("Connecting...", comment: "Video call status message")
            }
        case .InCall:
            return "\(conversation!.participants.first?.identity ?? "")"
        case .CallEnded:
            return NSLocalizedString("Call Ended", comment: "Video call status message")
        case .CallFailed:
            return NSLocalizedString("Call Failed", comment: "Video call status message")
        }
        
        return nil
    }
}

private extension VideoCallViewModel {
    
    private func fetchCallingProfileWithIdentity(identity: String) {
        
        APIProfileService
            .retrieveProfileWithTwilioUsername(identity)
            .subscribeNext { [weak self] (profile) in
                self?.callerProfile.value = profile
            }
            .addDisposableTo(disposeBag)
    }
}
