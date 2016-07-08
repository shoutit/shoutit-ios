//
//  ProfileCollectionShoutsCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit
import FBAudienceNetwork

final class ShoutsCollectionViewCell: UICollectionViewCell {
    
    enum Mode {
        case Regular
        case Expanded
    }
    
    
    weak var shoutImage: UIImageView? {
        return imageView
    }
    
    weak var name: UILabel? {
        return userNameLabel
    }
    
    weak var shoutTitle: UILabel? {
        return titleLabel
    }
    
    weak var shoutPrice: UILabel? {
        return priceLabel
    }
    
    weak var shoutType: UILabel? {
        return shoutTypeLabel
    }
    
    weak var shoutSubtitle: UILabel? {
        return subtitleLabel
    }
    
    weak var shoutCountryImage: UIImageView? {
        return shoutCountryFlagImageView
    }
    
    weak var shoutCategoryImage: UIImageView? {
        return shoutCategoryImageView
    }
    
    @IBOutlet weak var shoutBackgroundView: UIView?
    
    weak var shoutPromotionBackground: UIView?
    weak var shoutPromotionLabel: UILabel?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shoutTypeLabel: UILabel!
    @IBOutlet weak var shoutCountryFlagImageView: UIImageView!
    @IBOutlet weak var shoutCategoryImageView: UIImageView!
    @IBOutlet weak var messageIconImageView: UIImageView?
    @IBOutlet weak var bookmarkButton: UIButton?
    @IBOutlet weak var adChoicesView: FBAdChoicesView?
    
    var currentConstraints: [NSLayoutConstraint] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = 4
        layer.borderColor = UIColor(shoutitColor: .CellBackgroundGrayColor).CGColor
        layer.borderWidth = 1 / UIScreen.mainScreen().scale
        
        let (promotionView, promotionLabel) = createPromotionViews()
        
        self.shoutPromotionBackground = promotionView
        self.shoutPromotionLabel = promotionLabel
    }
    
    func hydrateWithDiscoverItem(discoverItem: DiscoverItem) {
        titleLabel.text = discoverItem.title
        
        if let imagePath = discoverItem.image, imageURL = NSURL(string: imagePath) {
            imageView.sh_setImageWithURL(imageURL, placeholderImage: UIImage.backgroundPattern())
        } else {
            imageView.image = UIImage.backgroundPattern()
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        
        self.name?.hidden = false
        self.shoutTitle?.hidden = false
        self.shoutPrice?.hidden = false
        self.bookmarkButton?.hidden = false
        
        self.shoutCountryImage?.hidden = false
        self.shoutType?.hidden = false
        self.messageIconImageView?.hidden = true
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        if let attributes = layoutAttributes as? ShoutsCollectionViewLayoutAttributes {
            setupViewForMode(attributes.mode)
        }
    }
    
    private func setupViewForMode(mode: Mode) {
        titleLabel.numberOfLines = mode == .Regular ? 1 : 2
        userNameLabel.hidden = mode != .Regular
        subtitleLabel.hidden = mode != .Expanded
        shoutTypeLabel.hidden = mode != .Expanded
        shoutCountryFlagImageView.hidden = mode != .Expanded
        shoutCategoryImageView.hidden = mode != .Expanded
        messageIconImageView?.hidden = mode != .Expanded
        setupConstraintsForMode(mode)
    }
    
    private func setupConstraintsForMode(mode: Mode) {
        
        let views: [String : AnyObject] = ["img" : imageView,
                                           "title" : titleLabel,
                                           "usr" : userNameLabel,
                                           "sub" : subtitleLabel,
                                           "price" : priceLabel,
                                           "type" : shoutTypeLabel,
                                           "flag" : shoutCountryFlagImageView,
                                           "category" : shoutCategoryImageView,
                                           "msg" : messageIconImageView!]
        currentConstraints.forEach { (constraint) in
            constraint.active = false
        }
        currentConstraints = []
        
        switch mode {
        case .Regular:
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[img]|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[img]-43-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[title]-(>=5)-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[usr]-(>=5)-[price]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += [NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 5)]
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[usr]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[price]-5-|", options: [], metrics: nil, views: views)
        case .Expanded:
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[img(100)]-10-[title]-22-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[img]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += [NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1, constant: 0)]
            currentConstraints += [NSLayoutConstraint(item: subtitleLabel, attribute: .Leading, relatedBy: .Equal, toItem: titleLabel, attribute: .Leading, multiplier: 1.0, constant: 0)]
            currentConstraints += [NSLayoutConstraint(item: shoutCountryFlagImageView, attribute: .Leading, relatedBy: .Equal, toItem: titleLabel, attribute: .Leading, multiplier: 1.0, constant: 0)]
            currentConstraints += [NSLayoutConstraint(item: subtitleLabel, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1, constant: 10)]
            currentConstraints += [NSLayoutConstraint(item: shoutTypeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: subtitleLabel, attribute: .CenterY, multiplier: 1, constant: 0)]
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[sub]-(>=20)-[type]-10-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[price]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[price]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[flag(21)]-6-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[category(21)]-6-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[msg(21)]-6-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[flag(21)]-21-[category(21)]-21-[msg(21)]", options: [], metrics: nil, views: views)
        }
        
        currentConstraints.forEach { (constraint) in
            constraint.active = true
        }
    }
}
