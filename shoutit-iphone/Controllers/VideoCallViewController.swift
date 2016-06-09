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
    @IBOutlet weak var remoteCameraView: UIView!
    @IBOutlet weak var localCameraView: UIView!
    @IBOutlet weak var chatInfoHeaderView: UIView!
    @IBOutlet weak var statusBarBackgroundView: UIView!
    @IBOutlet weak var callerNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var callButtonIconImageView: UIImageView!
    @IBOutlet weak var callButtonLabel: UILabel!
    @IBOutlet weak var audioButton: RoundSwitchableButton!
    @IBOutlet weak var videoButton: RoundSwitchableButton!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var transparentLogoImageView: UIImageView!
    @IBOutlet weak var callerAvatarImageView: UIImageView!
    private var hideableViews: [UIView] {
        return [chatInfoHeaderView, statusBarBackgroundView, audioButton, videoButton, endCallButton]
    }
    private var hideableViewsAreHidden: Bool {
        return endCallButton.hidden
    }
    
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
    private var remoteCameraViewRenderer: TWCVideoViewRenderer?
    private var localCameraViewRenderer: TWCVideoViewRenderer?
    private var remoteCameraRendererViewConstraints: [NSLayoutConstraint]?
    private var localCameraRendererViewConstraints: [NSLayoutConstraint]?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        viewModel.localMedia.delegate = self
        createCapturer()
        setupRX()
        setupGestureRecognizer()
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
    
    override func prefersStatusBarHidden() -> Bool {
        return hideableViewsAreHidden
    }
    
    deinit {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        audioButton
            .rx_tap
            .asDriver()
            .driveNext { [weak self] in
                self?.viewModel.muteAudio()
            }
            .addDisposableTo(disposeBag)
        
        videoButton
            .rx_tap
            .asDriver()
            .driveNext { [weak self] in
                self?.viewModel.disableVideo()
            }
            .addDisposableTo(disposeBag)
        
        viewModel.state
            .asDriver()
            .driveNext { [weak self] (state) in
                
                guard let `self` = self else { return }
                
                self.callButton.hidden = state != .ReadyForCall && state != .CallFailed
                self.callButtonLabel.hidden = state != .ReadyForCall && state != .CallFailed
                self.callButtonIconImageView.hidden = state != .ReadyForCall && state != .CallFailed
                self.setHideableViewsHidden(false)
                
                switch state {
                case .ReadyForCall:
                    self.messageLabel.text = nil
                    self.startPreview()
                case .InCall:
                    self.messageLabel.text = NumberFormatters.minutesAndSecondsUserDisplayableStringWithTimeInterval(self.viewModel.ticks.value)
                    self.adjustPreviewSize(CMVideoDimensions(width: 640, height: 480))
                    self.viewModel.startTimer()
                case .Calling:
                    self.messageLabel.text = NSLocalizedString("calling...", comment: "Video call status message")
                case .CallFailed:
                    self.messageLabel.text = NSLocalizedString("Call Failed", comment: "Video call status message")
                case .CallEnded:
                    self.messageLabel.text = NSLocalizedString("Call Ended", comment: "Video call status message")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.viewModel.stopTimer()
                }
            }
            .addDisposableTo(disposeBag)
        
        viewModel.callerProfile
            .asDriver()
            .driveNext { [weak self] (profile) in
                self?.callerNameLabel.text = profile?.name
                self?.callerAvatarImageView.sh_setImageWithURL(profile?.imagePath?.toURL(), placeholderImage: nil)
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
                self?.localCameraView.hidden = disabled
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
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControlsHidden))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @IBAction func startCalling() {
        viewModel.startCall()
    }
    
    @IBAction func endCall() {
        viewModel.endCall()
    }
    
    func toggleControlsHidden() {
        guard case .InCall = viewModel.state.value else { return }
        let hidden = hideableViewsAreHidden
        setHideableViewsHidden(!hidden)
    }
    
    private func setHideableViewsHidden(hidden: Bool) {
        
        if !hidden {
            self.hideableViews.forEach{ $0.hidden = false }
            self.transparentLogoImageView.hidden = true
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        UIView.animateWithDuration(0.3, animations: {
            let alpha: CGFloat = hidden ? 0.0 : 1.0
            self.hideableViews.forEach{ $0.alpha = alpha }
        }
        ) { (finished) in
            self.hideableViews.forEach{ $0.hidden = hidden }
            self.transparentLogoImageView.hidden = !hidden
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private func setCallerViewHidden(hidden: Bool) {
        remoteCameraView.hidden = hidden
        callerAvatarImageView.hidden = !hidden
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
        let maxWidth : CGFloat = min(round(CGRectGetWidth(self.view.bounds) * 0.35), 125.0)
        
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
        guard camera.capturing == false else { return }
        camera.startPreview()
        guard let previewView = camera.previewView else {
            return
        }
        localCameraView.addSubview(previewView)
        previewView.contentMode = .ScaleAspectFit
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
        addLocalCallRendererWithVideoTrack(videoTrack)
        videoTrack.delegate = self
    }
    
    func localMedia(media: TWCLocalMedia, didRemoveVideoTrack videoTrack: TWCVideoTrack) {
        removeLocalCallRendererFromVideoTrack(videoTrack)
    }
}

extension VideoCallViewController: TWCParticipantDelegate {
    
    func participant(participant: TWCParticipant, addedVideoTrack videoTrack: TWCVideoTrack) {
        if remoteCameraViewRenderer == nil {
            addRemoteCallRendererWithVideoTrack(videoTrack)
        }
    }
    
    func participant(participant: TWCParticipant, removedVideoTrack videoTrack: TWCVideoTrack) {
        removeRemoteCallRendererFromVideoTrack(videoTrack)
    }
    
    func participant(participant: TWCParticipant, enabledTrack track: TWCMediaTrack) {
        if let _ = track as? TWCVideoTrack {
            setCallerViewHidden(false)
        }
    }
    
    func participant(participant: TWCParticipant, disabledTrack track: TWCMediaTrack) {
        if let _ = track as? TWCVideoTrack {
            setCallerViewHidden(true)
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
        if let videoTrack = participant.media.videoTracks.first where remoteCameraViewRenderer == nil {
            addRemoteCallRendererWithVideoTrack(videoTrack)
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
        }
    }
}

extension VideoCallViewController: TWCCameraCapturerDelegate {
    
}

private extension VideoCallViewController {
    
    func addLocalCallRendererWithVideoTrack(videoTrack: TWCVideoTrack) {
        let renderer = createRendererForVideoTrack(videoTrack)
        if localCameraViewRenderer != nil {
            removeLocalCallRendererFromVideoTrack(videoTrack)
        }
        localCameraRendererViewConstraints = []
        let views = ["view" : renderer.view]
        localCameraView.addSubview(renderer.view)
        localCameraRendererViewConstraints! += NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: views)
        localCameraRendererViewConstraints! += NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: views)
        localCameraRendererViewConstraints!.forEach{ $0.active = true }
    }
    
    func removeLocalCallRendererFromVideoTrack(videoTrack: TWCVideoTrack) {
        if let constraints = localCameraRendererViewConstraints {
            constraints.forEach{ $0.active = false }
            localCameraRendererViewConstraints = nil
        }
        guard let renderer = localCameraViewRenderer else { return }
        videoTrack.removeRenderer(renderer)
        renderer.view.removeFromSuperview()
        localCameraViewRenderer = nil
    }
    
    func addRemoteCallRendererWithVideoTrack(videoTrack: TWCVideoTrack) {
        let renderer = createRendererForVideoTrack(videoTrack)
        if remoteCameraViewRenderer != nil {
            removeRemoteCallRendererFromVideoTrack(videoTrack)
        }
        remoteCameraRendererViewConstraints = []
        let views = ["view" : renderer.view]
        remoteCameraView.addSubview(renderer.view)
        remoteCameraRendererViewConstraints! += NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: views)
        remoteCameraRendererViewConstraints! += NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: views)
        remoteCameraRendererViewConstraints!.forEach{ $0.active = true }
    }
    
    func removeRemoteCallRendererFromVideoTrack(videoTrack: TWCVideoTrack) {
        if let constraints = remoteCameraRendererViewConstraints {
            constraints.forEach{ $0.active = false }
            remoteCameraRendererViewConstraints = nil
        }
        guard let renderer = remoteCameraViewRenderer else { return }
        videoTrack.removeRenderer(renderer)
        renderer.view.removeFromSuperview()
        remoteCameraViewRenderer = nil
    }
    
    func createRendererForVideoTrack(videoTrack: TWCVideoTrack) -> TWCVideoViewRenderer {
        let renderer = TWCVideoViewRenderer(delegate: self)
        renderer.view.translatesAutoresizingMaskIntoConstraints = false
        renderer.view.contentMode = .ScaleAspectFit
        videoTrack.addRenderer(renderer)
        return renderer
    }
}
