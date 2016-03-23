//
//  ProfileCollectionShoutsCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shoutTypeLabel: UILabel?
    @IBOutlet weak var shoutCountryFlagImageView: UIImageView?
    @IBOutlet weak var shoutCategoryImageView: UIImageView?
    
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
}
