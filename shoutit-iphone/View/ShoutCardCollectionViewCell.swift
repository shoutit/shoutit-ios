//
//  ShoutCardCollectionViewCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 30/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import QuartzCore
import ShoutitKit
import FBAudienceNetwork

class ShoutCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView : UIImageView!
    
    @IBOutlet var firstLineLabel : UILabel!
    @IBOutlet var secondLineLabel : UILabel!
    @IBOutlet var thirdLineLabel : UILabel!
    @IBOutlet var fourthLineLabel : UILabel!
    
    @IBOutlet var shadowView : UIView!
    @IBOutlet var roundedContentView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shadowView.layer.shadowColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
        shadowView.layer.shadowOffset = CGSizeMake(1, 1)
        shadowView.layer.shadowRadius = 1.0
        shadowView.layer.cornerRadius = 2.0
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.mainScreen().nativeScale
        shadowView.clipsToBounds = false
        
        roundedContentView.layer.cornerRadius = 2.0
        roundedContentView.clipsToBounds = true
        roundedContentView.layer.borderWidth = 1.0 / UIScreen.mainScreen().nativeScale
        roundedContentView.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
    }
}

extension ShoutCardCollectionViewCell : ReusableView, NibLoadableView {
    static var defaultReuseIdentifier: String { return "ShoutCardCollectionViewCell" }
    static var nibName: String { return "ShoutCard" }
}

extension ShoutCardCollectionViewCell {
    func bindWithShout(shout: Shout) {
        
        fillLabel(self.firstLineLabel, withText: shout.title)
        fillLabel(self.secondLineLabel, withText: shout.user?.name)
        fillLabel(self.thirdLineLabel, withText: NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency))
        fillLabel(self.fourthLineLabel, withText: shout.type()?.title())
        
        if let thumbPath = shout.thumbnailPath, thumbURL = NSURL(string: thumbPath) {
            self.imageView.sh_setImageWithURL(thumbURL, placeholderImage: UIImage.backgroundPattern())
        } else {
            self.imageView.image = UIImage.backgroundPattern()
        }
        
        if shout.type() == .Request {
            self.fourthLineLabel.textColor = UIColor(shoutitColor: .RequestColor)
        } else {
            self.fourthLineLabel.textColor = UIColor(shoutitColor: .OfferColor)
        }
    }
    
    func bindWithAd(ad: FBNativeAd) {
        fillLabel(self.firstLineLabel, withText: ad.title)
        fillLabel(self.secondLineLabel, withText: NSLocalizedString("Sponsored", comment: ""))
        fillLabel(self.thirdLineLabel, withText: ad.subtitle)
        fillLabel(self.fourthLineLabel, withText: ad.callToAction)
        
        ad.coverImage?.loadImageAsyncWithBlock({ [weak self] (image) -> Void in
            self?.imageView.image = image
        })
    }
}

extension UICollectionViewCell {
    func fillLabel(label: UILabel, withText text: String?) {
        if text?.isEmpty ?? true {
            label.hidden = true
        } else {
            label.hidden = false
            label.text = text
        }
    }
}