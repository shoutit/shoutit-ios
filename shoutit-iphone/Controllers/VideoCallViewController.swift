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
    @IBOutlet weak var callerCameraView: UIView!
    @IBOutlet weak var selfCameraView: UIView!
    @IBOutlet weak var chatInfoHeaderView: UIView!
    @IBOutlet weak var statusBarBackgroundView: UIView!
    @IBOutlet weak var callerNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var callButtonIconImageView: UIImageView!
    @IBOutlet weak var callButtonLabel: UILabel!
    @IBOutlet weak var audioButton: RoundSwitchableButton!
    @IBOutlet weak var videoButton: RoundSwitchableButton!
    
    // constraints
    @IBOutlet weak var selfCameraViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selfCameraViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selfCameraViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var selfCameraViewBottomConstraint: NSLayoutConstraint!
    
    // private
    private let disposeBag = DisposeBag()
    
    // state
    var viewModel: VideoCallViewModel!
    var camera : TWCCameraCapturer!
    private var cameraPreviewViewConstraints: [NSLayoutConstraint]?
    private var previewActive: Bool = false {
        didSet {
            if oldValue == previewActive { return }
            if previewActive { startPreview() }
            else { stopPreview() }
        }
    }
    private var callerCameraViewRenderer: TWCVideoViewRenderer?
    private var selfCameraViewRenderer: TWCVideoViewRenderer?
    private var callerCameraRendererViewConstraints: [NSLayoutConstraint]?
    private var selfCameraRendererViewConstraints: [NSLayoutConstraint]?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        viewModel.localMedia.delegate = self
        createCapturer()
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    deinit {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        viewModel.state
            .asDriver()
            .driveNext { [weak self] (state) in
                
                guard let `self` = self else { return }
                
                self.callButton.hidden = state != .ReadyForCall && state != .CallFailed
                self.callButtonLabel.hidden = state != .ReadyForCall && state != .CallFailed
                self.callButtonIconImageView.hidden = state != .ReadyForCall && state != .CallFailed
                self.previewActive = state == .ReadyForCall || state == .Calling || state == .CallFailed
                
                switch state {
                case .ReadyForCall:
                    if let username = self.viewModel.callerProfile.value?.username {
                        self.messageLabel.text = String.localizedStringWithFormat(NSLocalizedString("Video call with %@", comment: "Video call status message"), username)
                    }
                case .InCall:
                    self.messageLabel.text = NumberFormatters.minutesAndSecondsUserDisplayableStringWithTimeInterval(self.viewModel.ticks.value)
                    self.adjustPreviewSize(CMVideoDimensions(width: 640, height: 480))
                case .Calling:
                    self.messageLabel.text = NSLocalizedString("calling...", comment: "Video call status message")
                case .CallFailed:
                    self.messageLabel.text = NSLocalizedString("Call Failed", comment: "Video call status message")
                case .CallEnded:
                    self.messageLabel.text = NSLocalizedString("Call Ended", comment: "Video call status message")
                    self.dismissViewControllerAnimated(true, completion: nil)
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
            .driveNext { [weak self] (conversation) in
                conversation?.delegate = self
            }
            .addDisposableTo(disposeBag)
        
        viewModel.audioMuted
            .asDriver()
            .driveNext { [weak self] (muted) in
                self?.audioButton.setOn(muted)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.videoDisabled
            .asDriver()
            .driveNext { [weak self] (disabled) in
                self?.videoButton.setOn(disabled)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.ticks
            .asDriver()
            .driveNext {[weak self] (timeInteval) in
                guard let `self` = self else { return }
                guard case .InCall = self.viewModel.state.value else { return }
                self.messageLabel.text = NumberFormatters.minutesAndSecondsUserDisplayableStringWithTimeInterval(timeInteval)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.errorSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (error) in
                self?.showError(error)
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Actions
    
    @IBAction func startCalling() {
        viewModel.startCall()
    }
    
    @IBAction func endCall() {
        viewModel.endCall()
    }
}

private extension VideoCallViewController {
    
    private func createCapturer() {
        
        guard !Platform.isSimulator else { return }
        do {
            try camera = viewModel.localMedia.sh_addCameraTrack()
        } catch let error as NSError {
            print("Error: \(error)")
        }
        
        guard let videoTrack = camera.videoTrack else {
            fatalError("No video track created")
        }
        
        videoTrack.delegate = self
    }
    
    private func adjustPreviewSize(dimensions: CMVideoDimensions) {
        let maxWidth : CGFloat = min(round(CGRectGetWidth(self.view.bounds) * 0.35), 80.0)
        
        var height = round(CGFloat(dimensions.height / dimensions.width) * maxWidth)
        
        if height < 175 {
            height = 175.0
        }
        
        selfCameraViewWidthConstraint.constant = maxWidth
        selfCameraViewHeightConstraint.constant = height
        selfCameraViewLeadingConstraint.constant = 20.0
        selfCameraViewBottomConstraint.constant = 95.0
        view.layoutIfNeeded()
    }
    
    private func startPreview() {
        camera.startPreview()
        guard let previewView = camera.previewView else {
            return
        }
        selfCameraView.addSubview(previewView)
        previewView.contentMode = .ScaleAspectFill
        previewView.translatesAutoresizingMaskIntoConstraints = false
        cameraPreviewViewConstraints = []
        let views = ["preview" : previewView]
        cameraPreviewViewConstraints! += NSLayoutConstraint.constraintsWithVisualFormat("H:|[preview]|", options: [], metrics: nil, views: views)
        cameraPreviewViewConstraints! += NSLayoutConstraint.constraintsWithVisualFormat("V:|[preview]|", options: [], metrics: nil, views: views)
        cameraPreviewViewConstraints!.forEach{ $0.active = true }
        setPreviewOnFullScreen()
    }
    
    private func stopPreview() {
        guard let previewConstraints = cameraPreviewViewConstraints else { return }
        previewConstraints.forEach{ $0.active = false }
        cameraPreviewViewConstraints = nil
        camera.previewView?.removeFromSuperview()
        camera.stopPreview()
    }
    
    private func setPreviewOnFullScreen() {
        selfCameraViewWidthConstraint.constant = CGRectGetWidth(self.view.bounds)
        selfCameraViewHeightConstraint.constant = CGRectGetHeight(self.view.bounds)
        selfCameraViewLeadingConstraint.constant = 0.0
        selfCameraViewBottomConstraint.constant = 0.0
        view.layoutIfNeeded()
    }
    
    private func createRendererForVideoTrack(videoTrack: TWCVideoTrack) -> TWCVideoViewRenderer {
        let renderer = TWCVideoViewRenderer(delegate: self)
        renderer.view.translatesAutoresizingMaskIntoConstraints = false
        renderer.view.contentMode = .ScaleAspectFill
        videoTrack.addRenderer(renderer)
        return renderer
    }
    
    private func enableCallerCameraRendererWithTrack(track: TWCVideoTrack) {
        var renderer = callerCameraViewRenderer
        if renderer == nil {
            renderer = createRendererForVideoTrack(track)
            self.callerCameraViewRenderer = renderer
        }
        guard renderer?.view.superview == nil else { return }
        callerCameraRendererViewConstraints = []
        let views = ["view" : renderer!.view]
        callerCameraView.addSubview(renderer!.view)
        callerCameraRendererViewConstraints! += NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: views)
        callerCameraRendererViewConstraints! += NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: views)
        callerCameraRendererViewConstraints!.forEach{ $0.active = true }
    }
    
    private func enableSelfCameraRendererWithTrack(track: TWCVideoTrack) {
        var renderer = selfCameraViewRenderer
        if renderer == nil {
            renderer = createRendererForVideoTrack(track)
            self.selfCameraViewRenderer = renderer
        }
        guard renderer?.view.superview == nil else { return }
        selfCameraRendererViewConstraints = []
        let views = ["view" : renderer!.view]
        selfCameraView.addSubview(renderer!.view)
        selfCameraRendererViewConstraints! += NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: views)
        selfCameraRendererViewConstraints! += NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: views)
        selfCameraRendererViewConstraints!.forEach{ $0.active = true }
    }
    
    private func disableCallerCameraRenderer() {
        guard let constraints = callerCameraRendererViewConstraints else { return }
        constraints.forEach{ $0.active = false }
        callerCameraRendererViewConstraints = nil
        callerCameraViewRenderer?.view.removeFromSuperview()
    }
    
    private func disableSelfCameraRenderer() {
        guard let constraints = selfCameraRendererViewConstraints else { return }
        constraints.forEach{ $0.active = false }
        selfCameraRendererViewConstraints = nil
        selfCameraViewRenderer?.view.removeFromSuperview()
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
        previewActive = false
        enableSelfCameraRendererWithTrack(videoTrack)
        videoTrack.delegate = self
    }
    
    func localMedia(media: TWCLocalMedia, didRemoveVideoTrack videoTrack: TWCVideoTrack) {
        switch viewModel.state.value {
        case .CallFailed, .ReadyForCall, .Calling:
            previewActive = true
        default:
            break
        }
        disableSelfCameraRenderer()
    }
}

extension VideoCallViewController: TWCParticipantDelegate {
    
    func participant(participant: TWCParticipant, addedVideoTrack videoTrack: TWCVideoTrack) {
        enableCallerCameraRendererWithTrack(videoTrack)
    }
    
    func participant(participant: TWCParticipant, removedVideoTrack videoTrack: TWCVideoTrack) {
        disableCallerCameraRenderer()
    }
    
    func participant(participant: TWCParticipant, addedAudioTrack audioTrack: TWCAudioTrack) {
        if let videoTrack = participant.media.videoTracks.first {
            enableCallerCameraRendererWithTrack(videoTrack)
        }
    }
    
    func participant(participant: TWCParticipant, enabledTrack track: TWCMediaTrack) {
        if let videoTrack = track as? TWCVideoTrack {
            enableCallerCameraRendererWithTrack(videoTrack)
        }
    }
    
    func participant(participant: TWCParticipant, disabledTrack track: TWCMediaTrack) {
        if let _ = track as? TWCVideoTrack {
            disableCallerCameraRenderer()
        }
    }
}

extension VideoCallViewController: TWCConversationDelegate {
    
    func conversationEnded(conversation: TWCConversation, error: NSError) {
        viewModel.state.value = .CallEnded
    }
    
    func conversation(conversation: TWCConversation, didConnectParticipant participant: TWCParticipant) {
        viewModel.state.value = .InCall
        participant.delegate = self
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
        }
    }
}

extension VideoCallViewController: TWCCameraCapturerDelegate {
    
}
