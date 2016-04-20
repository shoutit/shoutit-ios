//
//  VideoCallViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift


enum VideoCallViewControllerState {
    case ReadyForCall
    case Calling
    case InCall
    case CallEnded
    case CallFailed
}

final class VideoCallViewController: UIViewController, TWCParticipantDelegate, TWCConversationDelegate, TWCCameraCapturerDelegate, TWCVideoTrackDelegate, TWCLocalMediaDelegate, TWCVideoViewRendererDelegate {

    @IBOutlet weak var videoPreView: UIView!
    @IBOutlet weak var myVideoPreView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var previewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var callButton: UIButton!
    private let disposeBag = DisposeBag()
    
    var remoteVideoRenderer: TWCVideoViewRenderer?
    
    var state : VideoCallViewControllerState = .ReadyForCall {
        didSet {
            invalidateMessage()
            
            if state == .CallEnded {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self.callButton.hidden = state != .ReadyForCall
        }
    }
    
    var conversation : TWCConversation? {
        didSet {
            if let conversation = conversation {
                conversation.delegate = self
            }
        }
    }
    
    var localMedia : TWCLocalMedia! {
        didSet {
            localMedia.delegate = self
            
        }
    }
    
    var callingToProfile: Profile?
    
    var camera : TWCCameraCapturer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if conversation != nil {
            state = .Calling
        } else {
            state = .ReadyForCall
        }
        
        if localMedia == nil {
            localMedia = TWCLocalMedia()
        }
        
        setPreviewOnFullScreen()
        
        if (!Platform.isSimulator) {
            createCapturer()
        }
    }
    
    @IBAction func startCalling() {
        
        state = .Calling
        
        guard let callingToProfile = callingToProfile else {
            self.endCall()
            return
        }

        
        
        Twilio.sharedInstance.sendInvitationTo(callingToProfile, media: localMedia) { [weak self] (conversation, error) in
            if let error = error {
                self?.state = .CallFailed
                self?.showError(error)
                
                
                
                return
            }
            
            if let conversation = conversation {
                self?.conversation = conversation
            }
        }
    }
    
    func invalidateMessage() {
        self.messageLabel.text = messageText()
    }
    
    func messageText() -> String? {
        switch self.state {
            case .ReadyForCall: return "Video call with \(callingToProfile?.username ?? "")"
            case .Calling: return "Connecting with \(conversation?.participants.first?.identity ?? "")..."
            case .InCall: return "\(conversation!.participants.first?.identity ?? "")"
            case .CallEnded: return "Call Ended"
            case .CallFailed: return "Call Failed"
        }
    }
    
    @IBAction func endCall() {
        self.conversation?.disconnect()
        state = .CallEnded
    }
    
    func createCapturer() {
        
        do {
            try self.camera = self.localMedia.sh_addCameraTrack()
        } catch let error as NSError {
            print("Error: \(error)")
        }
        
        guard let videoTrack = self.camera.videoTrack else {
            fatalError("No video track created")
        }
        
        videoTrack.delegate = self
        
        videoTrack.attach(self.myVideoPreView)
    }
    
    //MARK - TWCConversationDelegate
    
    func conversationEnded(conversation: TWCConversation, error: NSError) {
        state = .CallEnded
    }
    
    func conversation(conversation: TWCConversation, didConnectParticipant participant: TWCParticipant) {
        state = .InCall
        
        adjustPreviewSize(CMVideoDimensions(width: 640, height: 480))
        
        participant.delegate = self
        
        if let videoTrack = participant.media.videoTracks.first {
            videoTrack.attach(self.videoPreView)
        }
    }
    
    func conversation(conversation: TWCConversation, didFailToConnectParticipant participant: TWCParticipant, error: NSError) {
        state = .CallFailed
    }
    
    //MARK - TWCVideoTrackDelegate
    
    func videoTrack(track: TWCVideoTrack, dimensionsDidChange dimensions: CMVideoDimensions) {
        if state == .InCall {
            adjustPreviewSize(dimensions)
        } else {
            setPreviewOnFullScreen()
        }
    }
    
    func adjustPreviewSize(dimensions: CMVideoDimensions) {
        let maxWidth : CGFloat = min(round(CGRectGetWidth(self.view.bounds) * 0.35), 80.0)
        
        var height = round(CGFloat(dimensions.height / dimensions.width) * maxWidth)
        
        if height < 100 {
            height = 100.0
        }
        
        self.previewWidthConstraint.constant = maxWidth
        self.previewHeightConstraint.constant = height
        self.previewLeadingConstraint.constant = 20.0
        self.previewBottomConstraint.constant = 20.0
        self.view.layoutIfNeeded()
    }
    
    func setPreviewOnFullScreen() {
        self.previewWidthConstraint.constant = CGRectGetWidth(self.view.bounds)
        self.previewHeightConstraint.constant = CGRectGetHeight(self.view.bounds)
        self.previewLeadingConstraint.constant = 0.0
        self.previewBottomConstraint.constant = 0.0
        self.view.layoutIfNeeded()
    }
    
    //MARK - TWCLocalMediaDelegate
    
    func localMedia(media: TWCLocalMedia, didAddVideoTrack videoTrack: TWCVideoTrack) {
        videoTrack.attach(self.myVideoPreView)
        videoTrack.delegate = self
    }
    
    func localMedia(media: TWCLocalMedia, didRemoveVideoTrack videoTrack: TWCVideoTrack) {
        videoTrack.detach(self.myVideoPreView)
    }
    
    //MARK - TWCParticipantDelegate
    
    func participant(participant: TWCParticipant, addedVideoTrack videoTrack: TWCVideoTrack) {
        createRendererForVideoTrack(videoTrack)
    }
    
    func createRendererForVideoTrack(videoTrack: TWCVideoTrack) {
        let renderer = TWCVideoViewRenderer(delegate: self)
        
        renderer.view.bounds = self.videoPreView.frame
        renderer.view.contentMode = .ScaleAspectFit
        
        self.videoPreView.addSubview(renderer.view)
        
        NSLayoutConstraint(item: renderer.view, attribute: .Width, relatedBy: .Equal, toItem: self.videoPreView, attribute: .Width, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: renderer.view, attribute: .Height, relatedBy: .Equal, toItem: self.videoPreView, attribute: .Height, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: renderer.view, attribute: .CenterX, relatedBy: .Equal, toItem: self.videoPreView, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: renderer.view, attribute: .CenterY, relatedBy: .Equal, toItem: self.videoPreView, attribute: .CenterY, multiplier: 1.0, constant: 0).active = true
        
        videoTrack.addRenderer(renderer)
        
        self.remoteVideoRenderer = renderer
    }
    
    func participant(participant: TWCParticipant, removedVideoTrack videoTrack: TWCVideoTrack) {
        setPreviewOnFullScreen()
    }
    
    func participant(participant: TWCParticipant, addedAudioTrack audioTrack: TWCAudioTrack) {
        if let videoTrack = participant.media.videoTracks.first {
            videoTrack.attach(self.videoPreView)
        }
    }
    
    func participant(participant: TWCParticipant, enabledTrack track: TWCMediaTrack) {
        adjustPreviewSize(CMVideoDimensions(width: 640, height: 480))
    }
    
    func participant(participant: TWCParticipant, disabledTrack track: TWCMediaTrack) {
        setPreviewOnFullScreen()
    }
    
    func conversation(conversation: TWCConversation, didDisconnectParticipant participant: TWCParticipant) {
        if conversation.participants.count < 2 {
           state = .CallEnded
        }
    }
    
    //MARK- TWCVideoViewRendererDelegate
    
    func rendererDidReceiveVideoData(renderer: TWCVideoViewRenderer) {
        // Called when the first frame of video is received on the remote Participant's video track
        self.view.setNeedsLayout()
    }
    
    func renderer(renderer: TWCVideoViewRenderer, dimensionsDidChange dimensions: CMVideoDimensions) {
        // Called when the remote Participant's video track changes dimensions
        self.view.setNeedsLayout()
    }
    
    func renderer(renderer: TWCVideoViewRenderer, orientationDidChange orientation: TWCVideoOrientation) {
        // Called when the remote Participant's video track is rotated. Only ever called if 'rendererShouldRotateContent' returns true.
        self.view.setNeedsLayout()
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func rendererShouldRotateContent(renderer: TWCVideoViewRenderer) -> Bool {
        return true
    }

}
