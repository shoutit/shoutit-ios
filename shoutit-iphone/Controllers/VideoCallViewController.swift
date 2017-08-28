//
//  VideoCallViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

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
    @IBOutlet weak var switchCameraButton: UIButton!
    fileprivate var hideableViews: [UIView] {
        return [chatInfoHeaderView, statusBarBackgroundView, audioButton, videoButton, endCallButton]
    }
    fileprivate var hideableViewsAreHidden: Bool {
        return endCallButton.isHidden
    }
    
    // constraints
    @IBOutlet weak var selfCameraViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selfCameraViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selfCameraViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var selfCameraViewBottomConstraint: NSLayoutConstraint!
    
    // private
    fileprivate let disposeBag = DisposeBag()
    
    // state
    var viewModel: VideoCallViewModel!
    var camera : TWCCameraCapturer!
    fileprivate var cameraPreviewViewConstraints: [NSLayoutConstraint]?
    fileprivate var remoteCameraViewRenderer: TWCVideoViewRenderer?
    fileprivate var localCameraViewRenderer: TWCVideoViewRenderer?
    fileprivate var remoteCameraRendererViewConstraints: [NSLayoutConstraint]?
    fileprivate var localCameraRendererViewConstraints: [NSLayoutConstraint]?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        viewModel.localMedia.delegate = self
        createCapturer()
        setupRX()
        setupGestureRecognizer()
        switchCameraButton.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default
            .addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground,
                                                                object: nil, queue: nil) {[weak self] (_) in
            self?.viewModel.endCall()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return hideableViewsAreHidden
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - Setup
    
    fileprivate func setupRX() {
        
        audioButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.viewModel.muteAudio()
            })
            .addDisposableTo(disposeBag)
        
        videoButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.viewModel.disableVideo()
            })
            .addDisposableTo(disposeBag)
        
        viewModel.state
            .asDriver()
            .drive(onNext: { [weak self] (state) in
                
                guard let `self` = self else { return }
                
                self.callButton.isHidden = state != .readyForCall && state != .callFailed
                self.callButtonLabel.isHidden = state != .readyForCall && state != .callFailed
                self.callButtonIconImageView.isHidden = state != .readyForCall && state != .callFailed
                self.setHideableViewsHidden(false)
                
                switch state {
                case .readyForCall:
                    self.messageLabel.text = nil
                    self.startPreview()
                case .inCall:
                    self.messageLabel.text = NumberFormatters.minutesAndSecondsUserDisplayableStringWithTimeInterval(self.viewModel.ticks.value)
                    self.adjustPreviewSize(CMVideoDimensions(width: 640, height: 480))
                    self.viewModel.startTimer()
                case .calling:
                    self.messageLabel.text = NSLocalizedString("calling...", comment: "Video call status message")
                case .callFailed:
                    self.messageLabel.text = NSLocalizedString("Call Failed", comment: "Video call status message")
                    self.restartPreview()
                case .callEnded:
                    self.messageLabel.text = NSLocalizedString("Call Ended", comment: "Video call status message")
                    self.dismiss(animated: true, completion: nil)
                    self.viewModel.stopTimer()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.callerProfile
            .asDriver()
            .drive(onNext: { [weak self] (profile) in
                self?.callerNameLabel.text = profile?.name
                self?.callerAvatarImageView.sh_setImageWithURL(profile?.imagePath?.toURL(), placeholderImage: nil)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.conversation
            .asDriver()
            .drive(onNext: { [weak self] (conversation) in
                conversation?.delegate = self
            })
            .addDisposableTo(disposeBag)
        
        viewModel.audioMuted
            .asDriver()
            .drive(onNext: { [weak self] (muted) in
                self?.audioButton.setOn(muted)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.videoDisabled
            .asDriver()
            .drive(onNext: { [weak self] (disabled) in
                self?.videoButton.setOn(disabled)
                self?.localCameraView.isHidden = disabled
            })
            .addDisposableTo(disposeBag)
        
        viewModel.ticks
            .asDriver()
            .drive(onNext: { [weak self] (timeInteval) in
                guard let `self` = self else { return }
                guard case .inCall = self.viewModel.state.value else { return }
                self.messageLabel.text = NumberFormatters.minutesAndSecondsUserDisplayableStringWithTimeInterval(timeInteval)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.errorSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (error) in
                self?.showError(error)
            })
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func setupGestureRecognizer() {
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
    
    @IBAction func switchCamera(_ sender: UIButton) {
        self.camera.flipCamera()
    }
   
    
    func toggleControlsHidden() {
        guard case .inCall = viewModel.state.value else { return }
        let hidden = hideableViewsAreHidden
        setHideableViewsHidden(!hidden)
    }
    
    fileprivate func setHideableViewsHidden(_ hidden: Bool) {
        
        if !hidden {
            self.hideableViews.forEach{ $0.isHidden = false }
            self.transparentLogoImageView.isHidden = true
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            let alpha: CGFloat = hidden ? 0.0 : 1.0
            self.hideableViews.forEach{ $0.alpha = alpha }
        }, completion: { (finished) in
            self.hideableViews.forEach{ $0.isHidden = hidden }
            self.transparentLogoImageView.isHidden = !hidden
            self.setNeedsStatusBarAppearanceUpdate()
        }
        ) 
    }
    
    fileprivate func setCallerViewHidden(_ hidden: Bool) {
        remoteCameraView.isHidden = hidden
        callerAvatarImageView.isHidden = !hidden
    }
}

private extension VideoCallViewController {
    
    func createCapturer() {
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
        camera.delegate = self
    }
    
    func adjustPreviewSize(_ dimensions: CMVideoDimensions) {
        let maxWidth : CGFloat = min(round(self.view.bounds.width * 0.35), 125.0)
        
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
    
    func startPreview() {
        guard let camera = camera else { return }
        guard camera.isCapturing == false else { return }
        camera.startPreview()
        guard let previewView = camera.previewView else {
            return
        }
        localCameraView.addSubview(previewView)
        previewView.contentMode = .scaleAspectFit
        previewView.translatesAutoresizingMaskIntoConstraints = false
        cameraPreviewViewConstraints = []
        let views = ["preview" : previewView]
        cameraPreviewViewConstraints! += NSLayoutConstraint.constraints(withVisualFormat: "H:|[preview]|", options: [], metrics: nil, views: views)
        cameraPreviewViewConstraints! += NSLayoutConstraint.constraints(withVisualFormat: "V:|[preview]|", options: [], metrics: nil, views: views)
        cameraPreviewViewConstraints!.forEach{ $0.isActive = true }
        setPreviewOnFullScreen()
    }
    
    func restartPreview() {
        self.viewModel.reloadLocalMedia()
        stopPreview()
        createCapturer()
        startPreview()
    }
    
    func stopPreview() {
        guard let previewConstraints = cameraPreviewViewConstraints else { return }
        previewConstraints.forEach{ $0.isActive = false }
        cameraPreviewViewConstraints = nil
        camera.previewView?.removeFromSuperview()
        camera.stopPreview()
    }
    
    func setPreviewOnFullScreen() {
        selfCameraViewWidthConstraint.constant = self.view.bounds.width
        selfCameraViewHeightConstraint.constant = self.view.bounds.height
        selfCameraViewLeadingConstraint.constant = 0.0
        selfCameraViewBottomConstraint.constant = 0.0
        view.layoutIfNeeded()
    }
}

extension VideoCallViewController: TWCVideoViewRendererDelegate {
    
    func rendererDidReceiveVideoData(_ renderer: TWCVideoViewRenderer) {
        // Called when the first frame of video is received on the remote Participant's video track
        self.view.setNeedsLayout()
    }
    
    func renderer(_ renderer: TWCVideoViewRenderer, dimensionsDidChange dimensions: CMVideoDimensions) {
        // Called when the remote Participant's video track changes dimensions
        self.view.setNeedsLayout()
    }
    
    func renderer(_ renderer: TWCVideoViewRenderer, orientationDidChange orientation: TWCVideoOrientation) {
        // Called when the remote Participant's video track is rotated. Only ever called if 'rendererShouldRotateContent' returns true.
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    func rendererShouldRotateContent(_ renderer: TWCVideoViewRenderer) -> Bool {
        return true
    }
}

extension VideoCallViewController: TWCLocalMediaDelegate {
    
    func localMedia(_ media: TWCLocalMedia, didAdd videoTrack: TWCVideoTrack) {
        addLocalCallRendererWithVideoTrack(videoTrack)
        videoTrack.delegate = self
    }
    
    func localMedia(_ media: TWCLocalMedia, didRemove videoTrack: TWCVideoTrack) {
        removeLocalCallRendererFromVideoTrack(videoTrack)
        restartPreview()
    }
}

extension VideoCallViewController: TWCParticipantDelegate {
    
    func participant(_ participant: TWCParticipant, addedVideoTrack videoTrack: TWCVideoTrack) {
        if remoteCameraViewRenderer == nil {
            addRemoteCallRendererWithVideoTrack(videoTrack)
        }
    }
    
    func participant(_ participant: TWCParticipant, removedVideoTrack videoTrack: TWCVideoTrack) {
        removeRemoteCallRendererFromVideoTrack(videoTrack)
    }
    
    func participant(_ participant: TWCParticipant, enabledTrack track: TWCMediaTrack) {
        if let _ = track as? TWCVideoTrack {
            setCallerViewHidden(false)
        }
    }
    
    func participant(_ participant: TWCParticipant, disabledTrack track: TWCMediaTrack) {
        if let _ = track as? TWCVideoTrack {
            setCallerViewHidden(true)
        }
    }
}

extension VideoCallViewController: TWCConversationDelegate {
    
    func conversationEnded(_ conversation: TWCConversation, error: NSError) {
        viewModel.state.value = .callEnded
    }
    
    func conversation(_ conversation: TWCConversation, didConnect participant: TWCParticipant) {
        viewModel.state.value = .inCall
        participant.delegate = self
        if let videoTrack = participant.media.videoTracks.first, remoteCameraViewRenderer == nil {
            addRemoteCallRendererWithVideoTrack(videoTrack)
        }
    }
    
    func conversation(_ conversation: TWCConversation, didFailToConnectParticipant participant: TWCParticipant, error: NSError) {
        viewModel.state.value = .callFailed
    }
    
    func conversation(_ conversation: TWCConversation, didDisconnectParticipant participant: TWCParticipant) {
        if conversation.participants.count < 2 {
            viewModel.state.value = .callEnded
        }
    }
}

extension VideoCallViewController: TWCVideoTrackDelegate {
    
    func videoTrack(_ track: TWCVideoTrack, dimensionsDidChange dimensions: CMVideoDimensions) {
        if case .inCall = viewModel.state.value {
            adjustPreviewSize(dimensions)
        }
    }
}

extension VideoCallViewController: TWCCameraCapturerDelegate {}

private extension VideoCallViewController {
    
    func addLocalCallRendererWithVideoTrack(_ videoTrack: TWCVideoTrack) {
        let renderer = createRendererForVideoTrack(videoTrack)
        if localCameraViewRenderer != nil {
            removeLocalCallRendererFromVideoTrack(videoTrack)
        }
        localCameraRendererViewConstraints = []
        let views = ["view" : renderer.view]
        localCameraView.addSubview(renderer.view)
        localCameraRendererViewConstraints! += NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        localCameraRendererViewConstraints! += NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
        localCameraRendererViewConstraints!.forEach{ $0.isActive = true }
    }
    
    func removeLocalCallRendererFromVideoTrack(_ videoTrack: TWCVideoTrack) {
        if let constraints = localCameraRendererViewConstraints {
            constraints.forEach{ $0.isActive = false }
            localCameraRendererViewConstraints = nil
        }
        guard let renderer = localCameraViewRenderer else { return }
        videoTrack.removeRenderer(renderer)
        renderer.view.removeFromSuperview()
        localCameraViewRenderer = nil
    }
    
    func addRemoteCallRendererWithVideoTrack(_ videoTrack: TWCVideoTrack) {
        let renderer = createRendererForVideoTrack(videoTrack)
        if remoteCameraViewRenderer != nil {
            removeRemoteCallRendererFromVideoTrack(videoTrack)
        }
        remoteCameraRendererViewConstraints = []
        let views = ["view" : renderer.view]
        remoteCameraView.addSubview(renderer.view)
        remoteCameraRendererViewConstraints! += NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        remoteCameraRendererViewConstraints! += NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
        remoteCameraRendererViewConstraints!.forEach{ $0.isActive = true }
    }
    
    func removeRemoteCallRendererFromVideoTrack(_ videoTrack: TWCVideoTrack) {
        if let constraints = remoteCameraRendererViewConstraints {
            constraints.forEach{ $0.isActive = false }
            remoteCameraRendererViewConstraints = nil
        }
        guard let renderer = remoteCameraViewRenderer else { return }
        videoTrack.removeRenderer(renderer)
        renderer.view.removeFromSuperview()
        remoteCameraViewRenderer = nil
    }
    
    func createRendererForVideoTrack(_ videoTrack: TWCVideoTrack) -> TWCVideoViewRenderer {
        let renderer = TWCVideoViewRenderer(delegate: self)
        renderer.view.translatesAutoresizingMaskIntoConstraints = false
        renderer.view.contentMode = .scaleAspectFit
        videoTrack.addRenderer(renderer)
        return renderer
    }
}
