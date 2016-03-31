//
//  VideoCallViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum VideoCallViewControllerState {
    case ReadyForCall
    case Calling
    case InCall
    case CallEnded
    case CallFailed
}

class VideoCallViewController: UIViewController, TWCParticipantDelegate, TWCConversationDelegate, TWCCameraCapturerDelegate, TWCVideoTrackDelegate, TWCLocalMediaDelegate, TWCVideoViewRendererDelegate {

    @IBOutlet weak var videoPreView: UIView!
    @IBOutlet weak var myVideoPreView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var previewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewBottomConstraint: NSLayoutConstraint!
    
    var remoteVideoRenderer: TWCVideoViewRenderer?
    
    var state : VideoCallViewControllerState = .ReadyForCall {
        didSet {
            invalidateMessage()
            
            if state == .CallEnded {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    var conversation : TWCConversation! {
        didSet {
            conversation.delegate = self
        }
    }
    
    var localMedia: TWCLocalMedia! {
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
        
        if (!Platform.isSimulator) {
            createCapturer()
        }
        
        // mute for debug to keep silence in office
        localMedia.microphoneMuted = true
        
        setPreviewOnFullScreen()
    }
    
    @IBAction func startCalling() {
        
    }
    
    func invalidateMessage() {
        self.messageLabel.text = messageText()
    }
    
    func messageText() -> String? {
        switch self.state {
            case .ReadyForCall: return "Video call with \(conversation.participants.first?.identity ?? "")"
            case .Calling: return "Calling to \(conversation.participants.first?.identity ?? "")"
            case .InCall: return "\(conversation.participants.first?.identity ?? "")"
            case .CallEnded: return "Call Ended"
            case .CallFailed: return "Call Failed"
        }
    }
    
    @IBAction func endCall() {
        self.conversation.disconnect()
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
        adjustPreviewSize(dimensions)
    }
    
    func adjustPreviewSize(dimensions: CMVideoDimensions) {
        let maxWidth : CGFloat = round(CGRectGetWidth(self.view.bounds) * 0.35)
        let height = round(CGFloat(dimensions.height / dimensions.width) * maxWidth)
        
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
    
    func localMedia(media: TWCLocalMedia, didFailToAddVideoTrack videoTrack: TWCVideoTrack, error: NSError) {
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
        adjustPreviewSize(TWCVideoConstraintsSize640x480)
    }
    
    func participant(participant: TWCParticipant, disabledTrack track: TWCMediaTrack) {
        setPreviewOnFullScreen()
    }
    
    func conversation(conversation: TWCConversation, didDisconnectParticipant participant: TWCParticipant) {
        if self.conversation.participants.count < 2 {
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
        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func rendererShouldRotateContent(renderer: TWCVideoViewRenderer) -> Bool {
        return true
    }

}
