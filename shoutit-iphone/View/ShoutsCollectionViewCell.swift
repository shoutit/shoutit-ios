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
    
    enum Data {
        case Ad
        case Shout
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
    @IBOutlet weak var adChoicesView: FBAdChoicesView? {
        didSet {
            adChoicesView?.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    @IBOutlet weak var adIconImageView: UIImageView!
    @IBOutlet var adIconWidth : NSLayoutConstraint!
    @IBOutlet weak var adIconImage: UIImageView!
    
    var currentMode : ShoutsCollectionViewCell.Mode = .Regular
    var data : ShoutsCollectionViewCell.Data = .Shout {
        didSet {
            adjustChoicesView()
        }
    }
    
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
    
    func bindWithAd(Ad ad: FBNativeAd) {
        self.data = .Ad
        commonBindWithAd(Ad: ad)
        userNameLabel.text = NSLocalizedString("Sponsored", comment: "")
    }
    
    func bindWith(Shout shout: Shout) {
        self.data = .Shout
        commonBindWithShout(shout)
    }
    
    func adjustChoicesView() {
        setupViewForMode(currentMode)
        
        self.setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        if let attributes = layoutAttributes as? ShoutsCollectionViewLayoutAttributes {
            setupViewForMode(attributes.mode)
            currentMode = attributes.mode
        }
    }
    
    private func setupViewForMode(mode: Mode) {
        titleLabel.numberOfLines = mode == .Regular ? 1 : 2
        shoutSubtitle?.hidden = mode != .Expanded
        shoutTypeLabel.hidden = (mode != .Expanded || data == .Ad)
        shoutCountryFlagImageView.hidden =  (mode != .Expanded || data == .Ad)
        shoutCategoryImageView.hidden =  (mode != .Expanded || data == .Ad)
        messageIconImageView?.hidden = (mode != .Expanded || data == .Ad)
        userNameLabel.hidden = (mode == .Expanded && data == .Shout)
        shoutTitle?.hidden = false
        shoutPrice?.hidden = false
        bookmarkButton?.hidden = data == .Ad
        adChoicesView?.hidden = data == .Shout
        adIconImageView.hidden = data != .Ad
        setupConstraintsForMode(mode)
    }
    
    private func setupConstraintsForMode(mode: Mode) {
        
        let views: [String : AnyObject] = ["img" : imageView,
                                           "adIcon" : adIconImage,
                                           "title" : titleLabel,
                                           "usr" : userNameLabel,
                                           "sub" : subtitleLabel,
                                           "price" : priceLabel,
                                           "type" : shoutTypeLabel,
                                           "choices" : adChoicesView!,
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
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[img]-10-[adIcon(0)]", options: [], metrics: nil, views: views)
        case .Expanded:
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[img]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-4-[title(20)]-(-7)-[usr(20)]-10-[sub]", options: [], metrics: nil, views: views)
            currentConstraints += [NSLayoutConstraint(item: shoutTypeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: subtitleLabel, attribute: .CenterY, multiplier: 1, constant: 0)]
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[sub]-(>=20)-[type]-10-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[price]-5-|", options: [], metrics: nil, views: views)
            currentConstraints += [NSLayoutConstraint(item: subtitleLabel, attribute: .Leading, relatedBy: .Equal, toItem: adIconImageView, attribute: .Leading, multiplier: 1.0, constant: 10)]
            currentConstraints += [NSLayoutConstraint(item: userNameLabel, attribute: .Leading, relatedBy: .Equal, toItem: adIconImageView, attribute: .Trailing, multiplier: 1.0, constant: 10)]
            
            if data == .Ad {
                currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[img(100)]-10-[adIcon(24)]-10-[title]-5-|", options: [], metrics: nil, views: views)
                currentConstraints += [NSLayoutConstraint(item: priceLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 50)]
            } else {
                currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[img(100)]-10-[adIcon(0)]-0-[title]-5-|", options: [], metrics: nil, views: views)
                currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[price]-5-|", options: [], metrics: nil, views: views)
            }
            
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[flag(21)]-6-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[category(21)]-6-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[msg(21)]-6-|", options: [], metrics: nil, views: views)
            currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[flag(21)]-21-[category(21)]-21-[msg(21)]", options: [], metrics: nil, views: views)
        }
    
        currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[choices(80)]|", options: [], metrics: nil, views: views)
        currentConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[choices(16)]", options: [], metrics: nil, views: views)
        
        currentConstraints.forEach { (constraint) in
            constraint.active = true
        }
        
        
    }
}
