//
//  SHImageMediaItem.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 07/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MWPhotoBrowser

class SHImageMediaItem: JSQMediaItem, MWPhotoBrowserDelegate {
    var image: UIImage?
    var imageURL: String?
    var isOutgoing = false

    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return 1
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        if let image = self.image {
            let img = image.resizeImageProportionallyIntoNewSize(CGSizeMake(720, 720))
            return MWPhoto(image: img)
        } else if let imageUrl = self.imageURL {
            return MWPhoto(URL: NSURL(string: imageUrl))
        }
        return nil
    }
    
    override func mediaView() -> UIView! {
        if let image = self.image {
            let nibViews = NSBundle.mainBundle().loadNibNamed(Constants.Messages.SHImageMediaItem, owner: self, options: nil)
            if let view = nibViews[0] as? UIView, let imageView = (view.viewWithTag(1) as? UIImageView) {
                imageView.image = image
                view.backgroundColor = UIColor(shoutitColor: .ShoutGreen)
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(view, isOutgoing: self.isOutgoing)
                view.clipsToBounds = true
                view.layoutIfNeeded()
                return view
            }
        } else if let imageUrl = self.imageURL {
            let nibViews = NSBundle.mainBundle().loadNibNamed(Constants.Messages.SHImageMediaItem, owner: self, options: nil)
            let view = nibViews[0] as? UIView
            let imageView = (view?.viewWithTag(1) as? UIImageView)
            imageView?.setImageWithURL(NSURL(string: imageUrl), placeholderImage: UIImage(named: "image_placeholder"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            view?.backgroundColor = UIColor(shoutitColor: .ShoutGreen)
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(view, isOutgoing: self.isOutgoing)
            view?.clipsToBounds = true
            view?.layoutIfNeeded()
            return view
        }
        return nil
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        if(UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
            return CGSizeMake(315.0, 225.0)
        }
        return CGSizeMake(210.0, 150.0)
    }

}
