//
//  AdItemCell.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 01/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class AdItemCell: UICollectionViewCell, FBNativeAdDelegate {
    
    @IBOutlet weak var adIconImageView: UIImageView?
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adBodyLabel: UILabel?
    @IBOutlet weak var adCallToActionButton: UIButton!
    @IBOutlet weak var sponsoredLabel: UILabel!
    @IBOutlet weak var adCoverMediaView: FBMediaView!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adChoicesView: FBAdChoicesView!
    
    
//    var nativeAd: FBNativeAd!
//    var adChoices: FBAdChoicesView!
    
    func bindWithAd(ad: FBNativeAd) {
        
        if let title = ad.title {
            self.adTitleLabel.text = title
        }
        
        if let body = ad.body {
            self.adBodyLabel?.text = body
        }
        
        if let callToAction = ad.callToAction {
            self.adCallToActionButton.hidden = false
            self.adCallToActionButton.setTitle(callToAction, forState: .Normal)
        } else {
            self.adCallToActionButton.hidden = true
        }
        
        ad.icon?.loadImageAsyncWithBlock({(image) -> Void in
            self.adIconImageView?.image = image
        })
        self.adCoverMediaView.nativeAd = ad

            
            self.adChoicesView.nativeAd = ad
            self.adChoicesView.corner = .TopRight
            self.adChoicesView.hidden = false

        
        // Register the native ad view and its view controller with the native ad instance
//        nativeAd.registerViewForInteraction(self.adView, withViewController: self)
        
    }

    func nativeAd(ad: FBNativeAd, didFailWithError error: NSError) {
        NSLog("Ad failed to load with error: %@", error)
    }
    
}