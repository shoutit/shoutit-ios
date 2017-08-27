//
//  VideoCallViewModel.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 06.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

class VideoCallViewModel {
    
    enum State {
        case readyForCall
        case calling
        case inCall
        case callEnded
        case callFailed
    }
    
    let callerProfile: Variable<Profile?>
    let conversation: Variable<TWCConversation?>
    let audioMuted: Variable<Bool>
    let videoDisabled: Variable<Bool>
    fileprivate(set) var localMedia: TWCLocalMedia
    let state: Variable<State>
    let errorSubject: PublishSubject<Error> = PublishSubject()
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var callDurationTimer: Timer?
    let ticks: Variable<TimeInterval> = Variable(0.0)
    
    init(callerProfile: Profile?) {
        self.callerProfile = Variable(callerProfile)
        self.conversation = Variable(nil)
        self.localMedia = TWCLocalMedia()
        self.state = Variable(.readyForCall)
        self.audioMuted =  Variable(false)
        self.videoDisabled = Variable(false)
    }
    
    init(conversation: TWCConversation, localMedia: TWCLocalMedia?, invitation: TWCIncomingInvite?) {
        self.conversation = Variable(conversation)
        self.callerProfile = Variable(nil)
        self.localMedia = localMedia ?? TWCLocalMedia()
        self.state = Variable(.Calling)
        self.audioMuted =  Variable(localMedia?.microphoneMuted ?? false)
        self.videoDisabled = Variable(false)
        if let identity = conversation.participants.first?.identity {
            fetchCallingProfileWithIdentity(identity)
        } else if let identity = invitation?.from {
            fetchCallingProfileWithIdentity(identity)
        }
    }
    
    func reloadLocalMedia() {
        self.localMedia = TWCLocalMedia()
    }
    
    // MARK: - Actions
    
    func startCall() {
        
        guard let callingToProfile = callerProfile.value else {
            assertionFailure()
            endCall()
            return
        }
        
        state.value = .calling
        
        Account.sharedInstance
            .twilioManager
            .makeCallTo(callingToProfile, media: localMedia).subscribe({[weak self] (event) in
                switch event {
                case .error(let error):
                    self?.state.value = .CallFailed
                    self?.errorSubject.onNext(error)
                case .Next(let conversation):
                    self?.conversation.value = conversation
                default:
                    break
                }
                })
            .addDisposableTo(disposeBag)
    }
    
    func endCall() {
        
        conversation.value?.disconnect()
        
        let sentInvitations = Account.sharedInstance.twilioManager.sentInvitations
        for invite : TWCOutgoingInvite in sentInvitations {
            invite.cancel()
        }
        Account.sharedInstance.twilioManager.sentInvitations = []
        
        state.value = .callEnded
    }
    
    func muteAudio() {
        localMedia.microphoneMuted = !localMedia.microphoneMuted
        audioMuted.value = localMedia.microphoneMuted
    }
    
    func disableVideo() {
        guard let videoTrack = localMedia.videoTracks.first as? TWCLocalVideoTrack else {
            return
        }
        videoTrack.enabled = !videoTrack.enabled
        videoDisabled.value = !videoTrack.enabled
    }
}

// MARK: - Fetch

private extension VideoCallViewModel {
    
    func fetchCallingProfileWithIdentity(_ identity: String) {
        
        APIProfileService
            .retrieveProfileWithTwilioUsername(identity)
            .subscribe(onNext: { [weak self] (profile) in
                self?.callerProfile.value = profile
            })
            .addDisposableTo(disposeBag)
    }
}

// MARK: - Timer

extension VideoCallViewModel {
    
    func startTimer() {
        ticks.value = 0.0
        callDurationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTick(_:)), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        callDurationTimer?.invalidate()
        callDurationTimer = nil
    }
    
    @objc func timerTick(_ timer: Timer) {
        ticks.value = ticks.value + 1.0
    }
}
