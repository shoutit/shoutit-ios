//
//  VideoCallViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class VideoCallViewController: UIViewController, TWCVideoTrackDelegate, TWCCameraCapturerDelegate {

    @IBOutlet weak var videoPreView: UIView!
    @IBOutlet weak var myVideoPreView: UIView!
    
    
    var conversation : TWCConversation! {
        didSet {
            conversation.delegate = self
        }
    }
    
    var localMedia: TWCLocalMedia! {
        didSet {
            localMedia?.delegate = self
        }
    }
    
    private var camera: TWCCameraCapturer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.camera = TWCCameraCapturer(delegate: self, source: .FrontCamera)
        
        if (!Platform.isSimulator) {
            self.camera = self.localMedia?.addCameraTrack()
        }
        
        // We can attach our local camera Video Track to a UIView immediately
        if(self.camera != nil) {
            self.camera?.videoTrack?.delegate = self
            self.camera?.videoTrack?.attach(self.myVideoPreView)
        }
        
        
    }

}

extension VideoCallViewController: TWCConversationDelegate {
    func conversationEnded(conversation: TWCConversation, error: NSError) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func conversation(conversation: TWCConversation, didConnectParticipant participant: TWCParticipant) {
        debugPrint("connected new participant")
        participant.delegate = self
    }
    
    func conversation(conversation: TWCConversation, didDisconnectParticipant participant: TWCParticipant) {
        debugPrint("disconnected")
    }
    
    func conversation(conversation: TWCConversation, didFailToConnectParticipant participant: TWCParticipant, error: NSError) {
        debugPrint(error)
        debugPrint("fail")
    }
}

extension VideoCallViewController: TWCParticipantDelegate {
    func participant(participant: TWCParticipant, addedVideoTrack videoTrack: TWCVideoTrack) {
        videoTrack.attach(self.videoPreView)
    }
}

extension VideoCallViewController: TWCLocalMediaDelegate {
    func localMedia(media: TWCLocalMedia, didAddVideoTrack videoTrack: TWCVideoTrack) {
        videoTrack.attach(self.myVideoPreView)
    }
    
    func localMedia(media: TWCLocalMedia, didRemoveVideoTrack videoTrack: TWCVideoTrack) {
        videoTrack.detach(self.myVideoPreView)
    }
    
    func localMedia(media: TWCLocalMedia, didFailToAddVideoTrack videoTrack: TWCVideoTrack, error: NSError) {
        
    }
}
