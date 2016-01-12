//
//  SHVideoMediaItem.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 07/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class SHVideoMediaItem: JSQMediaItem {
    var video: SHMedia?
    var isOutgoing = false
    override func mediaView() -> UIView! {
        if let localThumbImage = self.video?.localThumbImage {
            let nibViews = NSBundle.mainBundle().loadNibNamed(Constants.Messages.SHVideoMediaItem, owner: self, options: nil)
            if let view = nibViews[0] as? UIView {
                let imageView = (view.viewWithTag(1) as? UIImageView)
                if let playImageView = (view.viewWithTag(2) as? UIImageView) {
                    playImageView.image = UIImage(named: "PlayButton")
                }
                imageView?.image = localThumbImage
                view.backgroundColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(view, isOutgoing: isOutgoing)
                view.clipsToBounds = true
                view.layoutIfNeeded()
                return view
            }
        } else if let video = self.video {
            let nibViews = NSBundle.mainBundle().loadNibNamed(Constants.Messages.SHVideoMediaItem, owner: self, options: nil)
            if let view = nibViews[0] as? UIView {
                let imageView = (view.viewWithTag(1) as? UIImageView)
                if let playImageView = (view.viewWithTag(2) as? UIImageView) {
                    playImageView.image = UIImage(named: "PlayButton")
                }
                if let _ = self.video?.thumbnailUrl {
                    imageView?.setImageWithURL(NSURL(string: video.thumbnailUrl), placeholderImage: UIImage(named: "image_placeholder"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                } else {
                    imageView?.image = UIImage(named: "no_image_available")
                }
                view.backgroundColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(view, isOutgoing: isOutgoing)
                view.clipsToBounds = true
                view.layoutIfNeeded()
                return view
            }
        }
        return nil
    }

}
