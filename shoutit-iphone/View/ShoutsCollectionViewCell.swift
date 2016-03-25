//
//  ProfileCollectionShoutsCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutsCollectionViewCell: UICollectionViewCell {
    
    enum Mode {
        case Regular
        case Expanded
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shoutTypeLabel: UILabel!
    @IBOutlet weak var shoutCountryFlagImageView: UIImageView!
    @IBOutlet weak var shoutCategoryImageView: UIImageView!
    @IBOutlet weak var messageIconImageView: UIImageView!
    
    var currentConstraints: [NSLayoutConstraint] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = 4
        layer.borderColor = UIColor(shoutitColor: .CellBackgroundGrayColor).CGColor
        layer.borderWidth = 1 / UIScreen.mainScreen().scale
    }
    
    func hydrateWithShout(shout: Shout) {
        titleLabel.text = shout.title
        userNameLabel?.text = shout.user.name
        
        if let publishedAt = shout.publishedAtEpoch {
            subtitleLabel?.text = "\(shout.user.name) - \(DateFormatters.sharedInstance.stringFromDateEpoch(publishedAt))"
        } else {
            subtitleLabel?.text = shout.user.name
        }
        
        priceLabel.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
        
        if let country = shout.location?.country, countryImage = UIImage(named:  country), countryImageView = shoutCountryFlagImageView {
            countryImageView.image = countryImage
        }
        
        if let categoryIcon = shout.category.icon, categoryImageView = shoutCategoryImageView {
            categoryImageView.sh_setImageWithURL(categoryIcon.toURL(), placeholderImage: nil)
        }
        
        if let thumbPath = shout.thumbnailPath, thumbURL = NSURL(string: thumbPath) {
            imageView.sh_setImageWithURL(thumbURL, placeholderImage: UIImage.backgroundPattern())
        } else {
            imageView.image = UIImage.backgroundPattern()
        }
        
        shoutTypeLabel?.text = shout.type()?.title()
        
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
        messageIconImageView.hidden = mode != .Expanded
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
                                           "msg" : messageIconImageView]
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
