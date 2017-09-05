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
    weak var adChoicesView: FBAdChoicesView? { get set }
    weak var adIconImage: UIImageView! { get set }
    
    func bindWith(Shout shout: Shout)
}

extension ShoutsCollectionViewCell : ShoutCell {}

extension ShoutCell where Self : UICollectionViewCell {
    func bindWithAd(Ad ad: FBNativeAd) {
        commonBindWithAd(Ad: ad)
    }
    
    func commonBindWithAd(Ad ad: FBNativeAd) {
        self.shoutTitle?.text = ad.title
        self.name?.text = NSLocalizedString("Sponsored", comment: "")
        self.shoutSubtitle?.text = ad.subtitle
        
        ad.coverImage?.loadAsync(block: { [weak self] (image) -> Void in
            self?.shoutImage?.image = image
        })
        
        ad.icon?.loadAsync(block: { [weak self] (image) in
            self?.adIconImage?.image = image
        })
        
        self.adChoicesView?.nativeAd = ad
        self.adChoicesView?.corner = .topRight
        self.adChoicesView?.isHidden = false
        
        self.shoutPrice?.text = ad.callToAction
        self.bookmarkButton?.isHidden = true
        self.shoutCategoryImage?.isHidden = true
        self.shoutCountryImage?.isHidden = true
        self.shoutType?.isHidden = true
        
        hidePromotion()
        setDefaultBackground()
    }
    
    func commonBindWithShout(_ shout: Shout) {
        self.shoutTitle?.text = shout.title ?? ""
        self.name?.text = shout.user?.name ?? ""
        
        if let publishedAt = shout.publishedAtEpoch, let user = shout.user {
            self.shoutSubtitle?.text = "\(user.name) - \(DateFormatters.sharedInstance.stringFromDateEpoch(publishedAt))"
        } else if let user = shout.user {
            self.shoutSubtitle?.text = user.name
        }
        
        self.setBookmarked(shout.isBookmarked ?? false)
        
        self.shoutPrice?.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
        
        if let country = shout.location?.country, let countryImage = UIImage(named:  country), let countryImageView = self.shoutCountryImage {
            countryImageView.image = countryImage
        }
        
        if let path = shout.category.icon, let url = path.toURL(), let categoryImageView = self.shoutCategoryImage {
            categoryImageView.kf.setImage(with:url, placeholder: nil)
        }
        
        
        if let thumbPath = shout.thumbnailPath, let thumbURL = URL(string: thumbPath) {
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
        
        self.shoutPromotionBackground?.isHidden = false
        self.shoutPromotionBackground?.backgroundColor = promotion.color()
        self.shoutPromotionLabel?.text = promotion.label?.name
        self.contentView.layoutIfNeeded()
        
        self.adChoicesView?.isHidden = true
        
        if let shoutPromotionBackground = shoutPromotionBackground {
            self.contentView.bringSubview(toFront: shoutPromotionBackground)
        }

    }
    
    func bindWith(Shout shout: Shout) {
        commonBindWithShout(shout)
    }
    
    func hidePromotion() {
        self.shoutPromotionBackground?.isHidden = true
    }
    
    func setDefaultBackground() {
        self.shoutBackgroundView?.backgroundColor = UIColor.white
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
        
        let leading = NSLayoutConstraint(item: shoutImage, attribute: .leading, relatedBy: .equal, toItem: promotionBackground, attribute: .leading, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: shoutImage, attribute: .top, relatedBy: .equal, toItem: promotionBackground, attribute: .top, multiplier: 1.0, constant: 0)
        let trailing = NSLayoutConstraint(item: self.contentView, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: promotionBackground, attribute: .trailing, multiplier: 1.0, constant: 0)
        let height = NSLayoutConstraint(item: promotionBackground, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 16)
        
        self.contentView.addSubview(promotionBackground)
        promotionBackground.addConstraint(height)
        
        self.addConstraints([leading, top, trailing])
        
        let promotionLabel = UILabel()
        promotionLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        promotionLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        promotionLabel.textColor = UIColor.white
        promotionLabel.font = UIFont.sh_systemFontOfSize(10.0, weight: .bold)
        promotionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        promotionBackground.addSubview(promotionLabel)
        
        let leadingLabel = NSLayoutConstraint(item: promotionLabel, attribute: .leading, relatedBy: .equal, toItem: promotionBackground, attribute: .leading, multiplier: 1.0, constant: 5)
        let topLabel = NSLayoutConstraint(item: promotionLabel, attribute: .top, relatedBy: .equal, toItem: promotionBackground, attribute: .top, multiplier: 1.0, constant: 0)
        let bottomLabel = NSLayoutConstraint(item: promotionLabel, attribute: .bottom, relatedBy: .equal, toItem: promotionBackground, attribute: .bottom, multiplier: 1.0, constant: 1)
        let trailingLabel = NSLayoutConstraint(item: promotionLabel, attribute: .trailing, relatedBy: .equal, toItem: promotionBackground, attribute: .trailing, multiplier: 1.0, constant: -5)
        
        self.addConstraints([leadingLabel, topLabel, bottomLabel, trailingLabel])
        
        return (promotionBackground, promotionLabel)
    }
}

extension ShoutCell {
    func setBookmarked(_ bookmarked: Bool) {
        if bookmarked {
            self.bookmarkButton?.setImage(UIImage(named:"bookmark_on"), for: UIControlState())
        } else {
            self.bookmarkButton?.setImage(UIImage(named:"bookmark_off"), for: UIControlState())
        }
    }
}
