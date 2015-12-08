//
//  SHShoutMediaItem.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 07/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class SHShoutMediaItem: JSQMediaItem {
    var shout: SHShout?
    var isOutgoing = false
    
    override func mediaView() -> UIView! {
        if let shout = self.shout {
            let nibViews = NSBundle.mainBundle().loadNibNamed(Constants.TableViewCell.SHShoutMessageCell, owner: self, options: nil)
            if let view = nibViews[0] as? UIView, let thumbnail = shout.thumbnail {
                if(self.shout?.thumbnail != "") {
                    (view.viewWithTag(1) as? UIImageView)?.setImageWithURL(NSURL(string: thumbnail), placeholderImage: UIImage(named: "image_placeholder"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                } else {
                    (view.viewWithTag(1) as? UIImageView)?.image = UIImage(named: "no_image_available")
                }
                view.viewWithTag(1)?.layer.cornerRadius = 15
                (view.viewWithTag(2) as? UILabel)?.text = self.shout?.title
                (view.viewWithTag(3) as? UILabel)?.text = self.shout?.text
                
                if let currency = self.shout?.currency, let price = self.shout?.price {
                    let price = String(format: "%@ %@", arguments: [currency, price])
                    (view.viewWithTag(4) as? UILabel)?.text = price
                }
                view.backgroundColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(view, isOutgoing: isOutgoing)
                view.clipsToBounds = true
                view.layoutIfNeeded()
                if let viewWithTag101 = view.viewWithTag(101) {
                    viewWithTag101.addGradientBlackToTransparent(false)
                }
                return view
            }
        } else {
            return nil
        }
        return nil
    }
    
    override func mediaViewDisplaySize () -> CGSize {
        if(UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
            return CGSizeMake(315.0, 225.0)
        }
        return CGSizeMake(210.0, 150.0)
    }
}
