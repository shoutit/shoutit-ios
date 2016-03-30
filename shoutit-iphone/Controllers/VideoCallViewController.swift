//
//  VideoCallViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class VideoCallViewController: UIViewController, TWCParticipantDelegate, TWCConversationDelegate, TWCCameraCapturerDelegate, TWCVideoTrackDelegate, TWCLocalMediaDelegate {

    @IBOutlet weak var videoPreView: UIView!
    @IBOutlet weak var myVideoPreView: UIView!
    
    
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
    
    var camera : TWCCameraCapturer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!Platform.isSimulator) {
            createCapturer()
        }
        
        // mute for debug to keep silence in office
        localMedia.microphoneMuted = true
    }
    
    @IBAction func endCall() {
        self.conversation.disconnect()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createCapturer() {
        self.camera = self.localMedia.addCameraTrack()
        
        guard self.camera != nil else {
            fatalError("Could not create camera")
        }
        
        guard let videoTrack = self.camera.videoTrack else {
            fatalError("No video track created")
        }
        
        videoTrack.delegate = self
        
        var error : UnsafeMutablePointer<NSError> = nil
        
        if self.localMedia.addTrack(videoTrack, error: error) == false {
            
        }

//        do {
//            try
//        } catch let error {
//            print(error)
//        }
//
//        
//        if let error = error {
//            debugPrint(error.localizedDescription)
//            debugPrint(error)
//            fatalError("Could not add track to local media")
//        }
        
        
        videoTrack.attach(self.myVideoPreView)
        
    }
    
    //MARK - TWCConversationDelegate
    
    func conversationEnded(conversation: TWCConversation, error: NSError) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func conversation(conversation: TWCConversation, didConnectParticipant participant: TWCParticipant) {
        debugPrint("\(#function)")
        participant.delegate = self
        
        if let videoTrack = participant.media.videoTracks.first {
            videoTrack.attach(self.videoPreView)
            
        }
    }
    
    func conversation(conversation: TWCConversation, didDisconnectParticipant participant: TWCParticipant) {
        debugPrint("Participant disconnected: " + participant.identity)
    }
    
    func conversation(conversation: TWCConversation, didReceiveTrackStatistics trackStatistics: TWCMediaTrackStatsRecord) {
        
    }
    
    func conversation(conversation: TWCConversation, didFailToConnectParticipant participant: TWCParticipant, error: NSError) {
        debugPrint("Participant failed to connect: " + participant.identity)
        debugPrint("With error: " + error.localizedDescription)
    }
    
    //MARK - TWCCameraCapturerDelegate
    
    func cameraCapturerWasInterrupted(capturer: TWCCameraCapturer) {
        debugPrint("\(#function)")
    }
    
    func cameraCapturer(capturer: TWCCameraCapturer, didStopRunningWithError error: NSError) {
        print(error)
        debugPrint("\(#function)")
    }
    
    func cameraCapturer(capturer: TWCCameraCapturer, didStartWithSource source: TWCVideoCaptureSource) {
        debugPrint("\(#function)")
    }
    
    //MARK - TWCVideoTrackDelegate
    
    func videoTrack(track: TWCVideoTrack, dimensionsDidChange dimensions: CMVideoDimensions) {
        debugPrint("\(#function)")
    }
    
    //MARK - TWCLocalMediaDelegate
    
    func localMedia(media: TWCLocalMedia, didAddVideoTrack videoTrack: TWCVideoTrack) {
        videoTrack.attach(self.myVideoPreView)
        videoTrack.delegate = self
        debugPrint("\(#function)")
    }
    
    func localMedia(media: TWCLocalMedia, didRemoveVideoTrack videoTrack: TWCVideoTrack) {
        videoTrack.detach(self.myVideoPreView)
        debugPrint("\(#function)")
    }
    
    func localMedia(media: TWCLocalMedia, didFailToAddVideoTrack videoTrack: TWCVideoTrack, error: NSError) {
        print(error)
        debugPrint("\(#function)")
    }
    
    //MARK - TWCParticipantDelegate
    
    func participant(participant: TWCParticipant, addedVideoTrack videoTrack: TWCVideoTrack) {
        debugPrint("\(#function)")
        
        videoTrack.attach(self.videoPreView)
        videoTrack.delegate = self
    }
    
    func participant(participant: TWCParticipant, addedAudioTrack audioTrack: TWCAudioTrack) {
        debugPrint("\(#function)")
        
        
        if let videoTrack = participant.media.videoTracks.first {
            videoTrack.attach(self.videoPreView)
        }

    }
    
    func participant(participant: TWCParticipant, enabledTrack track: TWCMediaTrack) {
        debugPrint("\(#function)")
    }
    
    func participant(participant: TWCParticipant, disabledTrack track: TWCMediaTrack) {
        debugPrint("\(#function)")
    }
    

}

