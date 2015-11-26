//
//  SHCreateVideoCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

protocol SHCreateVideoCollectionViewCellDelegate {
    func removeVideo(media: SHMedia)
}

class SHCreateVideoCollectionViewCell: UICollectionViewCell {
    
    var player: AVPlayer?
    var media: SHMedia? {
        didSet {
            setMedia()
        }
    }
    var delegate: SHCreateVideoCollectionViewCellDelegate?
    
    @IBOutlet weak var playerHolder: UIView!
    @IBOutlet weak var playstopButton: UIButton!
    
    @IBAction func playstopAction(sender: AnyObject) {
        if let player = self.player {
            if player.rate > 0 && player.error == nil {
                self.player?.pause()
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.playstopButton.alpha = 1
                })
            } else {
                self.player?.play()
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.playstopButton.alpha = 0
                })
            }
        }
    }
    
    @IBAction func removeAction(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Remove?", comment: "Remove?"), preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Cancel) { (action) in
            // Do Nothing
        }
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if let media = self.media, let delegate = self.delegate {
                delegate.removeVideo(media)
            }
        }))
        let window = UIApplication.sharedApplication().keyWindow
        window?.makeKeyAndVisible()
        window?.rootViewController = UIViewController()
        window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
      //  UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func playerItemDidReachEnd() {
        self.player?.seekToTime(kCMTimeZero)
        UIView.animateWithDuration(0.1) { () -> Void in
            self.playstopButton.alpha = 1
        }
    }
    
    override func prepareForReuse() {
        self.player?.pause()
        self.player = nil
        self.playstopButton.alpha = 1
        self.delegate = nil
        self.media = nil
    }
    
    // MARK - Private
    private func setMedia() {
        if let mediaItem = media {
            let videoFile: String
            if mediaItem.upload, let localUrl = mediaItem.localUrl {
                videoFile = localUrl.absoluteString
            } else {
                videoFile = mediaItem.url
            }
            
            let url = NSURL(string: videoFile)
            // Create an AVURLAsset with an NSURL containing the path to the video
            let asset = AVURLAsset(URL: url!)
            
            // Create an AVPlayerItem using the asset
            let playerItem = AVPlayerItem(asset: asset)
            
            // Create the AVPlayer using the playeritem
            self.player = AVPlayer(playerItem: playerItem)
            
            // Create an AVPlayerLayer using the player
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = self.playerHolder.frame
            
            // Add it to your view's sublayers
            self.playerHolder.layer.addSublayer(playerLayer)
            
            // You can play/pause using the AVPlayer object
            self.player?.play()
            self.player?.pause()
            
            // You can seek to a specified time
            self.player?.seekToTime(kCMTimeZero)
            //[self.playstopButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
            // It is also useful to use the AVPlayerItem's notifications and Key-Value
            // Observing on the AVPlayer's status and the AVPlayerLayer's readForDisplay property
            // (to know when the video is ready to be played, if for example you want to cover the
            // black rectangle with an image until the video is ready to be played)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
            let tapGesture = UITapGestureRecognizer(target: self, action: "playstopAction:")
            self.playerHolder.addGestureRecognizer(tapGesture)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
