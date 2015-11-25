//
//  SHAmazonVideoCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 23/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import MediaPlayer

class SHAmazonVideoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var playerView: UIView!
    private var player: MPMoviePlayerController?
    
    func setVideo(video: SHMedia) {
        self.player = MPMoviePlayerController(contentURL: NSURL(string: video.url))
        self.backgroundColor = UIColor.darkGrayColor()
        if let player = self.player {
            player.shouldAutoplay = false
            player.prepareToPlay()
            player.controlStyle = MPMovieControlStyle.Embedded
            
            player.view.frame = self.playerView.bounds
            player.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
            if let view = player.view {
                self.playerView.addSubview(view)
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didExitFullScreen:"), name: MPMoviePlayerDidExitFullscreenNotification, object: self.player)
        
    }
    
    override func prepareForReuse() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerDidExitFullscreenNotification, object: nil)
    }
    
    func didExitFullScreen(sender: AnyObject) {
        if let window = UIApplication.sharedApplication().delegate?.window {
            let rootViewController = window?.rootViewController
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    window?.rootViewController = nil
                    window?.rootViewController = rootViewController
                })
            })
        }
        
    }
}
