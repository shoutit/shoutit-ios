//
//  SHYouTubeVideoCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 23/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHYouTubeVideoCollectionViewCell: UICollectionViewCell, YTPlayerViewDelegate {
    @IBOutlet weak var ytPlayerView: YTPlayerView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        if let activityIndicator = self.activityIndicatorView {
            activityIndicator.stopAnimating()
        }
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToQuality quality: YTPlaybackQuality) {
        
    }
    
    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        self.activityIndicatorView.stopAnimating()
    }
    
}
