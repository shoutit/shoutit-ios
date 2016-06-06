//
//  VideoCallViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class VideoCallViewController: UIViewController {

    // UI
    @IBOutlet weak var videoPreView: UIView!
    @IBOutlet weak var myVideoPreView: UIView!
    @IBOutlet weak var chatInfoHeaderView: UIView!
    @IBOutlet weak var callerNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var audioButton: RoundSwitchableButton!
    @IBOutlet weak var videoButton: RoundSwitchableButton!
    
    // constraints
    @IBOutlet weak var previewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewBottomConstraint: NSLayoutConstraint!
    
    // private
    private let disposeBag = DisposeBag()
    
    // state
    var viewModel: VideoCallViewModel!
    var remoteVideoRenderer: TWCVideoViewRenderer?
    var camera : TWCCameraCapturer!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        viewModel.localMedia.delegate = self
        setPreviewOnFullScreen()
        if (!Platform.isSimulator) {
            createCapturer()
        }
        setupRX()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = true
        NSNotificationCenter
            .defaultCenter()
            .addObserverForName(UIApplicationDidEnterBackgroundNotification,
                                                                object: nil, queue: nil) {[weak self] (_) in
            self?.viewModel.endCall()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        viewModel.state
            .asDriver()
            .driveNext { [weak self] (state) in
                self?.invalidateMessage()
                self?.callButton.hidden = state != .ReadyForCall
                
                switch state {
                case .ReadyForCall:
                    break
                case .InCall:
                    break
                case .Calling:
                    break
                case .CallFailed:
                    break
                case .CallEnded:
                    self?.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            .addDisposableTo(disposeBag)
        
        viewModel.callerProfile
            .asDriver()
            .driveNext { [weak self] (profile) in
                self?.callerNameLabel.text = profile?.name
            }
            .addDisposableTo(disposeBag)
        
        viewModel.conversation
            .asDriver()
            .driveNext { (conversation) in
                conversation?.delegate = self
            }
            .addDisposableTo(disposeBag)
        
        viewModel.errorSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (error) in
                self?.showError(error)
            }
            .addDisposableTo(disposeBag)
    }
    
    private func createCapturer() {
        
        do {
            try self.camera = viewModel.localMedia.sh_addCameraTrack()
        } catch let error as NSError {
            print("Error: \(error)")
        }
        
        guard let videoTrack = self.camera.videoTrack else {
            fatalError("No video track created")
        }
        
        videoTrack.delegate = self
        videoTrack.attach(self.myVideoPreView)
    }
    
    // MARK: - Actions
    
    @IBAction func startCalling() {
        viewModel.startCall()
    }
    
    func invalidateMessage() {
        self.messageLabel.text = messageText()
    }
    
    @IBAction func endCall() {
        viewModel.endCall()
    }
}

private extension VideoCallViewController {
    
    private func adjustPreviewSize(dimensions: CMVideoDimensions) {
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
    
    private func setPreviewOnFullScreen() {
        self.previewWidthConstraint.constant = CGRectGetWidth(self.view.bounds)
        self.previewHeightConstraint.constant = CGRectGetHeight(self.view.bounds)
        self.previewLeadingConstraint.constant = 0.0
        self.previewBottomConstraint.constant = 0.0
        self.view.layoutIfNeeded()
    }
    
    private func createRendererForVideoTrack(videoTrack: TWCVideoTrack) {
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
}

extension VideoCallViewController: TWCVideoViewRendererDelegate {
    
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

extension VideoCallViewController: TWCLocalMediaDelegate {
    
    func localMedia(media: TWCLocalMedia, didAddVideoTrack videoTrack: TWCVideoTrack) {
        videoTrack.attach(self.myVideoPreView)
        videoTrack.delegate = self
    }
    
    func localMedia(media: TWCLocalMedia, didRemoveVideoTrack videoTrack: TWCVideoTrack) {
        videoTrack.detach(self.myVideoPreView)
    }
}

extension VideoCallViewController: TWCParticipantDelegate {
    
    func participant(participant: TWCParticipant, addedVideoTrack videoTrack: TWCVideoTrack) {
        createRendererForVideoTrack(videoTrack)
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
}

extension VideoCallViewController: TWCConversationDelegate {
    
    func conversationEnded(conversation: TWCConversation, error: NSError) {
        viewModel.state.value = .CallEnded
    }
    
    func conversation(conversation: TWCConversation, didConnectParticipant participant: TWCParticipant) {
        
        viewModel.state.value = .InCall
        adjustPreviewSize(CMVideoDimensions(width: 640, height: 480))
        participant.delegate = self
        
        if let videoTrack = participant.media.videoTracks.first {
            videoTrack.attach(self.videoPreView)
        }
    }
    
    func conversation(conversation: TWCConversation, didFailToConnectParticipant participant: TWCParticipant, error: NSError) {
        viewModel.state.value = .CallFailed
    }
    
    func conversation(conversation: TWCConversation, didDisconnectParticipant participant: TWCParticipant) {
        if conversation.participants.count < 2 {
            viewModel.state.value = .CallEnded
        }
    }
}

extension VideoCallViewController: TWCVideoTrackDelegate {
    
    func videoTrack(track: TWCVideoTrack, dimensionsDidChange dimensions: CMVideoDimensions) {
        if case .InCall = viewModel.state.value {
            adjustPreviewSize(dimensions)
        } else {
            setPreviewOnFullScreen()
        }
    }
}

extension VideoCallViewController: TWCCameraCapturerDelegate {
    
}
