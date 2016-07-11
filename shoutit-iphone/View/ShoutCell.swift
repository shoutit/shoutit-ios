//
//  ShoutCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 15/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit
import FBAudienceNetwork

protocol ShoutCell {
    weak var shoutImage: UIImageView? { get }
    weak var name: UILabel? { get }
    weak var shoutTitle: UILabel? { get }
    weak var shoutPrice: UILabel? { get }
    weak var shoutType: UILabel? { get }
    weak var bookmarkButton: UIButton? { get }
    weak var shoutSubtitle: UILabel? { get }
    weak var shoutCountryImage: UIImageView? { get }
    weak var shoutCategoryImage: UIImageView? { get }
    weak var shoutBackgroundView: UIView? { get }
    weak var shoutPromotionBackground: UIView? { get set }
    weak var shoutPromotionLabel: UILabel? { get set }
    weak var adChoicesView: FBAdChoicesView! { get set }
    weak var adIconImage: UIImageView! { get set }
    
    func bindWith(Shout shout: Shout)
}

extension SHShoutItemCell : ShoutCell {}
extension ShoutsCollectionViewCell : ShoutCell {}

extension ShoutCell where Self : UICollectionViewCell {
    func bindWithAd(Ad ad: FBNativeAd) {
        commonBindWithAd(Ad: ad)
    }
    
    func commonBindWithAd(Ad ad: FBNativeAd) {
        self.shoutTitle?.text = ad.title
        self.name?.text = NSLocalizedString("Sponsored", comment: "")
        self.shoutSubtitle?.text = ad.subtitle
        
        ad.coverImage?.loadImageAsyncWithBlock({(image) -> Void in
            self.shoutImage?.image = image
        })
        
        ad.icon?.loadImageAsyncWithBlock({ (image) in
            self.adIconImage?.image = image
        })
        
        self.adChoicesView?.nativeAd = ad
        self.adChoicesView?.corner = .TopRight
        self.adChoicesView?.hidden = false
        
        self.shoutPrice?.text = ad.callToAction
        self.bookmarkButton?.hidden = true
        self.shoutCategoryImage?.hidden = true
        self.shoutCountryImage?.hidden = true
        self.shoutType?.hidden = true
        
        hidePromotion()
        setDefaultBackground()
    }
    
    func commonBindWithShout(shout: Shout) {
        self.shoutTitle?.text = shout.title ?? ""
        self.name?.text = shout.user?.name ?? ""
        
        if let publishedAt = shout.publishedAtEpoch, user = shout.user {
            self.shoutSubtitle?.text = "\(user.name) - \(DateFormatters.sharedInstance.stringFromDateEpoch(publishedAt))"
        } else if let user = shout.user {
            self.shoutSubtitle?.text = user.name
        }
        
        self.setBookmarked(shout.isBookmarked)
        
        self.shoutPrice?.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
        
        if let country = shout.location?.country, countryImage = UIImage(named:  country), countryImageView = self.shoutCountryImage {
            countryImageView.image = countryImage
        }
        
        if let path = shout.category.icon, url = path.toURL(), categoryImageView = self.shoutCategoryImage {
            categoryImageView.kf_setImageWithURL(url, placeholderImage: nil)
        }
        
        
        if let thumbPath = shout.thumbnailPath, thumbURL = NSURL(string: thumbPath) {
            self.shoutImage?.sh_setImageWithURL(thumbURL, placeholderImage: UIImage.backgroundPattern())
        } else {
            self.shoutImage?.image = UIImage.backgroundPattern()
        }
        
        self.shoutType?.text = shout.type()?.title()
        
        guard let promotion = shout.promotion else {
            hidePromotion()
            setDefaultBackground()
            return
        }
        
        guard promotion.isExpired == false else {
            hidePromotion()
            setDefaultBackground()
            return
        }
        
        self.shoutBackgroundView?.backgroundColor = promotion.backgroundUIColor()
        
        self.shoutPromotionBackground?.hidden = false
        self.shoutPromotionBackground?.backgroundColor = promotion.color()
        self.shoutPromotionLabel?.text = promotion.label?.name
        self.contentView.layoutIfNeeded()
        
        self.adChoicesView?.hidden = true
        
        if let shoutPromotionBackground = shoutPromotionBackground {
            self.contentView.bringSubviewToFront(shoutPromotionBackground)
        }

    }
    
    func bindWith(Shout shout: Shout) {
        commonBindWithShout(shout)
    }
    
    func hidePromotion() {
        self.shoutPromotionBackground?.hidden = true
    }
    
    func setDefaultBackground() {
        self.shoutBackgroundView?.backgroundColor = UIColor.whiteColor()
    }
}

extension ShoutCell where Self: UICollectionViewCell {
    func createPromotionViews() -> (UIView?, UILabel?) {
        let promotionBackground = UIView()
        promotionBackground.translatesAutoresizingMaskIntoConstraints = false
        
        guard let shoutImage = self.shoutImage else {
            assertionFailure("Shout Image should be presented")
            return (nil, nil)
        }
        
        let leading = NSLayoutConstraint(item: shoutImage, attribute: .Leading, relatedBy: .Equal, toItem: promotionBackground, attribute: .Leading, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: shoutImage, attribute: .Top, relatedBy: .Equal, toItem: promotionBackground, attribute: .Top, multiplier: 1.0, constant: 0)
        let trailing = NSLayoutConstraint(item: self.contentView, attribute: .Trailing, relatedBy: .GreaterThanOrEqual, toItem: promotionBackground, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let height = NSLayoutConstraint(item: promotionBackground, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 16)
        
        self.contentView.addSubview(promotionBackground)
        promotionBackground.addConstraint(height)
        
        self.addConstraints([leading, top, trailing])
        
        let promotionLabel = UILabel()
        promotionLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        promotionLabel.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        promotionLabel.textColor = UIColor.whiteColor()
        promotionLabel.font = UIFont.sh_systemFontOfSize(10.0, weight: .Bold)
        promotionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        promotionBackground.addSubview(promotionLabel)
        
        let leadingLabel = NSLayoutConstraint(item: promotionLabel, attribute: .Leading, relatedBy: .Equal, toItem: promotionBackground, attribute: .Leading, multiplier: 1.0, constant: 5)
        let topLabel = NSLayoutConstraint(item: promotionLabel, attribute: .Top, relatedBy: .Equal, toItem: promotionBackground, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottomLabel = NSLayoutConstraint(item: promotionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: promotionBackground, attribute: .Bottom, multiplier: 1.0, constant: 1)
        let trailingLabel = NSLayoutConstraint(item: promotionLabel, attribute: .Trailing, relatedBy: .Equal, toItem: promotionBackground, attribute: .Trailing, multiplier: 1.0, constant: -5)
        
        self.addConstraints([leadingLabel, topLabel, bottomLabel, trailingLabel])
        
        return (promotionBackground, promotionLabel)
    }
}

extension ShoutCell {
    func setBookmarked(bookmarked: Bool) {
        if bookmarked {
            self.bookmarkButton?.setImage(UIImage(named:"bookmark_on"), forState: .Normal)
        } else {
            self.bookmarkButton?.setImage(UIImage(named:"bookmark_off"), forState: .Normal)
        }
    }
}
