//
//  SHShoutItemCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutItemCell: UICollectionViewCell {
    
    @IBOutlet weak var shoutImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var shoutTitle: UILabel!
    @IBOutlet weak var shoutPrice: UILabel!
    @IBOutlet weak var shoutType: UILabel?
    @IBOutlet weak var shoutCountryImage: UIImageView?
    @IBOutlet weak var shoutCategoryImage: UIImageView?
}

extension SHShoutItemCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        self.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        self.layer.cornerRadius = 3.0
    }
    
    func bindWith(Shout shout: Shout) {
        self.shoutTitle.text = shout.title
        
        if let publishedAt = shout.publishedAtEpoch {
            self.name.text = "\(shout.text) \(DateFormatters.sharedInstance.stringFromDateEpoch(publishedAt))"
        } else {
            self.name.text = shout.text
        }
        
        self.shoutPrice.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
        
        if let country = shout.location?.country, countryImage = UIImage(named:  country), countryImageView = self.shoutCategoryImage {
            countryImageView.image = countryImage
        }
        
        if let categoryIcon = shout.category.icon, categoryImageView = self.shoutCategoryImage {
            categoryImageView.sh_setImageWithURL(NSURL(string: categoryIcon), placeholderImage: nil)
        }
        
        if let thumbPath = shout.thumbnailPath, thumbURL = NSURL(string: thumbPath) {
            self.shoutImage.sh_setImageWithURL(thumbURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        }
        
    }
    
    func bindWith(DiscoverItem discoverItem: DiscoverItem) {
        self.shoutTitle.text = discoverItem.title
        
        if let imagePath = discoverItem.image, imageURL = NSURL(string: imagePath) {
            self.shoutImage.sh_setImageWithURL(imageURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        }
        
    }
    
    override func prepareForReuse() {
        self.shoutImage.image = nil
    }
}
