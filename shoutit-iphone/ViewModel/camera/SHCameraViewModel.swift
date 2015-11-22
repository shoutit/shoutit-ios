//
//  SHCameraControlViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary

class SHCameraViewModel: NSObject, ViewControllerModelProtocol, AVCaptureFileOutputRecordingDelegate, SHPhotoPreviewViewControllerDelegate, SHVideoPreviewViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let viewController: SHCameraViewController
    
    private var session: AVCaptureSession?
    private var backgroundRecordingID = UIBackgroundTaskInvalid
    private var sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var movieFileOutput: AVCaptureFileOutput?
    private var stillImageOutput: AVCaptureStillImageOutput?
    
    private var lockInterfaceRotation: Bool = false
    private var secondsLeft: Int = 0
    private var hours: Int = 0
    private var minutes: Int = 0
    private var seconds: Int = 0
    private var runTimeErrorHandlingObserver: NSObjectProtocol?
    private var timer: NSTimer?
    
    required init(viewController: SHCameraViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        self.viewController.title = NSLocalizedString("Camera", comment: "Camera")
        self.viewController.timerLabel.text = String(format: "%02d:%02d", 0, self.viewController.timeToRecord)
        
        let session = AVCaptureSession()
        if self.viewController.isVideo {
            session.sessionPreset = AVCaptureSessionPresetHigh
        } else {
            session.sessionPreset = AVCaptureSessionPresetPhoto
        }
        self.session = session
        self.viewController.previewView.setSession(session)
        self.checkDeviceAuthorizationStatus()
        
        dispatch_async(sessionQueue) { () -> Void in
            self.backgroundRecordingID = UIBackgroundTaskInvalid
            let videoDevice: AVCaptureDevice?
            if self.viewController.isVideoCV {
                videoDevice = self.deviceWithMediaType(AVMediaTypeVideo, position: AVCaptureDevicePosition.Front)
            } else {
                videoDevice = self.deviceWithMediaType(AVMediaTypeVideo, position: AVCaptureDevicePosition.Back)
            }
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                }
                
                let audioDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as? AVCaptureDevice
                let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                if session.canAddInput(audioDeviceInput) {
                    session.addInput(audioDeviceInput)
                }
                
                let movieFileOutput = AVCaptureMovieFileOutput()
                if session.canAddOutput(movieFileOutput) {
                    session.addOutput(movieFileOutput)
                    let connection = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
                    if connection.supportsVideoStabilization {
                        connection.preferredVideoStabilizationMode = .Auto
                    }
                    self.movieFileOutput = movieFileOutput
                }
                
                let stillImageOutput = AVCaptureStillImageOutput()
                if session.canAddOutput(stillImageOutput) {
                    stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                    session.addOutput(stillImageOutput)
                    self.stillImageOutput = stillImageOutput
                }
                
                self.setFlashMode(AVCaptureFlashMode.Off, device: self.videoDeviceInput?.device)
                self.configureSessionForVideo(self.viewController.isVideo)
            } catch {
                // Error starting capture device
                log.error("Error starting capture device")
            }
        }
        self.secondsLeft = self.viewController.timeToRecord
    }
    
    func viewWillAppear() {
        self.viewController.setMode(true)
        self.viewController.startRecording(false)
        dispatch_async(sessionQueue) { () -> Void in
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput?.device)
            self.runTimeErrorHandlingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionRuntimeErrorNotification, object: self.session, queue: nil, usingBlock: { (notification) -> Void in
                dispatch_async(self.sessionQueue, { () -> Void in
                    self.session?.startRunning()
                    self.viewController.startRecording(false)
                })
            })
            self.session?.startRunning()
            self.autorotateCamera(nil)
        }
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "autorotateCamera:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        dispatch_async(self.sessionQueue) { () -> Void in
            self.session?.stopRunning()
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput?.device)
            if let observer = self.runTimeErrorHandlingObserver {
                NSNotificationCenter.defaultCenter().removeObserver(observer)
            }
        }
    }
    
    func destroy() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func toggleMovieRecording() {
        dispatch_async(self.sessionQueue) { () -> Void in
            if let movieFileOutput = self.movieFileOutput {
                if !movieFileOutput.recording {
                    self.lockInterfaceRotation = true
                    if UIDevice.currentDevice().multitaskingSupported {
                        // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until SHCamera returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when SHCamera is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                        self.backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
                    }
                    
                    var outputFilePath: String? = ((NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("movie") as NSString).stringByAppendingPathExtension("mov")
                    
                    if var filePath = outputFilePath {
                        while NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                            filePath = ((NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(String(format: "movie-%ld", NSDate().timeIntervalSince1970)) as NSString).stringByAppendingPathExtension("mov")!
                        }
                        outputFilePath = filePath
                    }
                    
                    if let outFile = outputFilePath {
                        do {
                            try NSFileManager.defaultManager().removeItemAtURL(NSURL.fileURLWithPath(outFile))
                        } catch {
                            // Do Nothing
                        }
                        
                        if movieFileOutput.connectionWithMediaType(AVMediaTypeVideo).active {
                            movieFileOutput.startRecordingToOutputFileURL(NSURL.fileURLWithPath(outFile), recordingDelegate: self)
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.viewController.startRecording(true)
                        })
                    }
                } else {
                    movieFileOutput.stopRecording()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.viewController.startRecording(false)
                    })
                    self.resetTimer()
                }
            }
        }
    }
    
    func toggleVideoButton() {
        self.viewController.toggleVideoButton()
        self.configureSessionForVideo(self.viewController.isVideo)
    }
    
    func openLibrary() {
        if self.viewController.isVideo {
            self.startVideoBrowserFromViewController(self.viewController)
        } else {
            self.startPhotoBrowserFromViewController(self.viewController)
        }
    }
    
    func closeCamera() {
        self.viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func changeCamera() {
        self.blurPreviewView(false)
        dispatch_async(self.sessionQueue) { () -> Void in
            if  let currentVideoDevice = self.videoDeviceInput?.device {
                var preferredPosition = AVCaptureDevicePosition.Unspecified
                let currentPosition = currentVideoDevice.position
                
                switch currentPosition {
                case .Unspecified:
                    preferredPosition = .Back
                case .Back:
                    preferredPosition = .Front
                case .Front:
                    preferredPosition = .Back
                }
                
                if let videoDevice = self.deviceWithMediaType(AVMediaTypeVideo, position: preferredPosition) {
                    do {
                        let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                        self.session?.beginConfiguration()
                        self.session?.removeInput(self.videoDeviceInput)
                        if ((self.session?.canAddInput(videoDeviceInput)) != nil) {
                            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: currentVideoDevice)
                            NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: videoDevice)
                            self.session?.addInput(videoDeviceInput)
                            self.videoDeviceInput = videoDeviceInput
                        }
                        self.session?.commitConfiguration()
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.blurPreviewView(false)
                        })
                    } catch {
                        // Do Nothing
                    }
                }
                
            }
        }
    }
    
    func snapStillImage() {
        var videoOrientation = AVCaptureVideoOrientation.Portrait
        switch self.viewController.currentInterfaceOrientation {
        case .Portrait:
            videoOrientation = .Portrait
        case .PortraitUpsideDown:
            videoOrientation = .PortraitUpsideDown
        case .LandscapeLeft:
            videoOrientation = .LandscapeLeft
        case .LandscapeRight:
            videoOrientation = .LandscapeRight
        case .Unknown:
            videoOrientation = .Portrait
        }
        self.runStillImageCaptureAnimation()
        self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = videoOrientation
        dispatch_async(self.sessionQueue) { () -> Void in
            self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo), completionHandler: { (data, error) -> Void in
                if let imageDataSampleBuffer = data {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    let image = UIImage(data: imageData)
                    if let photoPreviewViewController = UIStoryboard.getCamera().instantiateViewControllerWithIdentifier(Constants.ViewControllers.PHOTO_PREVIEW) as? SHPhotoPreviewViewController {
                        photoPreviewViewController.photo = image
                        photoPreviewViewController.delegate = self
                        self.viewController.navigationController?.pushViewController(photoPreviewViewController, animated: false)
                    }
                }
            })
        }
    }
    
    func switchFlash() {
        if let videoDeviceInput = self.videoDeviceInput where videoDeviceInput.device.hasFlash {
            let flashMode: AVCaptureFlashMode
            switch videoDeviceInput.device.flashMode {
            case .On:
                flashMode = .Off
            case .Off:
                flashMode = .Auto
            case .Auto:
                flashMode = .On
            }
            setFlashMode(flashMode, device: videoDeviceInput.device)
            self.viewController.setFlashButtonMode(videoDeviceInput.device.flashMode)
        }
    }
    
    func subjectAreaDidChange() {
        self.focus(AVCaptureFocusMode.ContinuousAutoFocus, exposureMode: AVCaptureExposureMode.ContinuousAutoExposure, point: CGPointMake(0.5, 0.5), monitorSubjectAreaChange: false)
    }
    
    func isSessionRunningAndDeviceAuthorized() -> Bool {
        if let session = self.session {
            return session.running && self.viewController.deviceAuthorized
        }
        return false
    }
    
    // MARK - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // 1 - Get media type
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            // 2 - Dismiss image picker
            picker.dismissViewControllerAnimated(true, completion: nil)
            // Handle a movie capture
            if (kUTTypeMovie as NSString) == mediaType {
                if let videoPreviewViewController = UIStoryboard.getCamera().instantiateViewControllerWithIdentifier(Constants.ViewControllers.VIDEO_PREVIEW) as? SHVideoPreviewViewController {
                    videoPreviewViewController.videoFileURL = info[UIImagePickerControllerMediaURL] as? NSURL
                    videoPreviewViewController.delegate = self
                    self.viewController.navigationController?.pushViewController(videoPreviewViewController, animated: false)
                }
            } else if (kUTTypeImage as NSString) == mediaType {
                if let photoPreviewViewController = UIStoryboard.getCamera().instantiateViewControllerWithIdentifier(Constants.ViewControllers.PHOTO_PREVIEW) as? SHPhotoPreviewViewController {
                    photoPreviewViewController.photo = info[UIImagePickerControllerOriginalImage] as? UIImage
                    photoPreviewViewController.delegate = self
                    self.viewController.navigationController?.pushViewController(photoPreviewViewController, animated: false)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK - SHPhotoPreviewViewControllerDelegate
    func didPhotoPreviewFinish(image: UIImage) {
        if let delegate = self.viewController.delegate {
            delegate.didCameraFinish(image)
        }
    }
    
    // MARK - AVCaptureFileOutputRecordingDelegate
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if error != nil {
            log.error("Error with capturing video \(error.localizedDescription)")
        }
        self.lockInterfaceRotation = false
        if let videoPreviewViewController = UIStoryboard.getCamera().instantiateViewControllerWithIdentifier(Constants.ViewControllers.VIDEO_PREVIEW) as? SHVideoPreviewViewController {
            videoPreviewViewController.videoFileURL = outputFileURL
            videoPreviewViewController.delegate = self
            self.viewController.navigationController?.pushViewController(videoPreviewViewController, animated: false)
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.countdownTimer()
        }
    }
    
    // MARK - SHVideoPreviewViewControllerDelegate
    func didVideoPreviewFinish(tempVideoFileURL: NSURL, thumbnailImage: UIImage) {
        if let delegate = self.viewController.delegate {
            delegate.didCameraFinish(tempVideoFileURL, thumbnailImage: thumbnailImage)
        }
    }
    
    // MARK - Timer
    func updateCounter() {
        if(self.secondsLeft > 0 ) {
            self.secondsLeft--
            self.hours = self.secondsLeft / 3600
            self.minutes = (self.secondsLeft % 3600) / 60
            self.seconds = (self.secondsLeft % 3600) % 60
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.viewController.timerLabel.text = String(format: "%02d:%02d", self.minutes, self.secondsLeft)
            })
        } else {
            self.toggleMovieRecording()
            self.timer?.invalidate()
        }
    }
    
    // MARK - Private
    private func startVideoBrowserFromViewController(controller: UIViewController) {
        // 1 - Validations
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            return;
        }
        // 2 - Get image picker
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .SavedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = true
        mediaUI.videoMaximumDuration = Double(self.viewController.timeToRecord)
        mediaUI.delegate = self
        // 3 - Display image picker
        controller.presentViewController(mediaUI, animated: true, completion: nil)
    }
    
    private func startPhotoBrowserFromViewController(controller: UIViewController) {
        // 1 - Validations
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            return;
        }
        // 2 - Get image picker
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .SavedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeImage as String]
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use true
        //mediaUI.allowsEditing = true
        mediaUI.delegate = self
        // 3 - Display image picker
        controller.presentViewController(mediaUI, animated: true, completion: nil)
    }
    
    private func checkDeviceAuthorizationStatus() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { (granted) -> Void in
            self.viewController.deviceAuthorized = granted
            if !granted {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alert = UIAlertController(title: "Shoutit!", message: NSLocalizedString("CameraNoPermissions", comment: "Shoutit doesn’t have permission to use Camera, please change privacy settings"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertActionStyle.Default, handler: nil))
                    self.viewController.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    private func countdownTimer() {
        self.secondsLeft = self.viewController.timeToRecord
        self.hours = 0
        self.seconds = 0
        self.minutes = 0
        if ((self.timer?.valid) != nil) {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateCounter", userInfo: nil, repeats: true)
    }
    
    private func configureSessionForVideo(isVideo: Bool) {
        self.blurPreviewView(true)
        dispatch_async(self.sessionQueue) { () -> Void in
            self.session?.beginConfiguration()
            if self.viewController.isVideo {
                self.session?.sessionPreset = AVCaptureSessionPresetHigh
            } else {
                self.session?.sessionPreset = AVCaptureSessionPresetPhoto
            }
            self.session?.commitConfiguration()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.viewController.isVideo {
                    self.viewController.constraintTopPreviewView.constant = 0
                    self.viewController.constraintBottomPreviewView.constant = 0
                    self.viewController.view.setNeedsUpdateConstraints()
                    self.viewController.view.setNeedsLayout()
                } else {
                    self.viewController.constraintTopPreviewView.constant = 44
                    self.viewController.constraintBottomPreviewView.constant = 96
                    self.viewController.view.setNeedsUpdateConstraints()
                    self.viewController.view.setNeedsLayout()
                }
                self.blurPreviewView(false)
            })
        }
    }
    
    private func blurPreviewView(blur: Bool) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.viewController.visualEffectView.alpha = blur ? 1 : 0
                }, completion: { (finished) -> Void in
                    self.viewController.visualEffectView.hidden = !blur
            })
        }
    }
    
    func autorotateCamera(notification: NSNotification?) {
        if !self.lockInterfaceRotation {
            let orientation = UIDevice.currentDevice().orientation
            let interfaceOrientation = UIInterfaceOrientation(rawValue: orientation.rawValue)!
            self.viewController.rotateViewTo(interfaceOrientation)
            var videoOrientation: AVCaptureVideoOrientation = .Portrait
            switch self.viewController.currentInterfaceOrientation {
            case .Portrait:
                videoOrientation = .Portrait
            case .LandscapeLeft:
                videoOrientation = .LandscapeLeft
            case .LandscapeRight:
                videoOrientation = .LandscapeRight
            case .PortraitUpsideDown:
                videoOrientation = .PortraitUpsideDown
            default:
                videoOrientation = .Portrait
            }
            self.movieFileOutput?.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = videoOrientation
        }
    }
    
    private func resetTimer() {
        self.secondsLeft = self.viewController.timeToRecord
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController.timerLabel.text = String(format: "%02d:%02d", 0, self.secondsLeft)
            self.timer?.invalidate()
        }
    }
    
    private func deviceWithMediaType(mediaType: String, position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice = devices.first as? AVCaptureDevice
        for device in devices {
            if device.position == position {
                captureDevice = device as? AVCaptureDevice
                break
            }
        }
        return captureDevice
    }
    
    private func setFlashMode(flashMode: AVCaptureFlashMode, device: AVCaptureDevice?) {
        if let avDevice = device where avDevice.hasFlash && avDevice.isFlashModeSupported(flashMode) {
            do {
                try avDevice.lockForConfiguration()
                avDevice.flashMode = flashMode
                avDevice.unlockForConfiguration()
            } catch {
                log.error("couldn't lock for flash mode : \(flashMode)")
            }
        }
    }
    
    private func focus(focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, point: CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(self.sessionQueue) { () -> Void in
            if let device = self.videoDeviceInput?.device {
                do {
                    try device.lockForConfiguration()
                    if device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                        device.focusMode = focusMode
                        device.focusPointOfInterest = point
                    }
                    if device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                        device.exposureMode = exposureMode
                        device.exposurePointOfInterest = point
                    }
                    device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                    device.unlockForConfiguration()
                } catch {
                    // Do Nothing
                }
            }
        }
    }
    
    private func runStillImageCaptureAnimation() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController.previewView.layer.opacity = 0.0
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.viewController.previewView.layer.opacity = 1.0
            })
        }
    }
    
}
