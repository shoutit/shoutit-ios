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
        
        ad.icon?.loadImageAsyncWithBlock({ (image) -> Void in
            self.adIconImageView?.image = image
        })
        
        self.adCoverMediaView.nativeAd = ad
        self.adChoicesView.nativeAd = ad
        self.setNeedsDisplay()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let ad = adChoicesView.nativeAd {
            ad.unregisterView()
        }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.adChoicesView.updateFrameFromSuperview()
    }
}