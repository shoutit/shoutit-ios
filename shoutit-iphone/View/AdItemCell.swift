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
    
    @IBOutlet weak var adIconImageView: UIImageView!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adBodyLabel: UILabel?
    @IBOutlet weak var adCallToActionButton: UIButton!
    @IBOutlet weak var sponsoredLabel: UILabel!
    @IBOutlet weak var adCoverMediaView: FBMediaView?
    @IBOutlet weak var adView: UIView!

    
    var nativeAd: FBNativeAd!
    var adChoicesView: FBAdChoicesView!
    
//    func showNativeAd() {
//        nativeAd = FBNativeAd(placementID: "YOUR_PLACEMENT_ID")
//        nativeAd.delegate = self
//        nativeAd.loadAd()
//    }
    
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
            self.adIconImageView.image = image
        })
        self.adCoverMediaView?.nativeAd = ad
        
//         Add adChoicesView
        if let nativeAd = nativeAd {
            
            let adChoices = FBAdChoicesView(nativeAd: nativeAd)
            self.adView.addSubview(adChoices)
            adChoices.updateFrameFromSuperview()
            adChoicesView = adChoices
        }
        
        // Register the native ad view and its view controller with the native ad instance
//        nativeAd.registerViewForInteraction(self.adView, withViewController: self)
    }
    
    func nativeAd(nativeAd: FBNativeAd, didFailWithError error: NSError) {
        NSLog("Ad failed to load with error: %@", error)
    }
    
}