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
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var shoutTitle: UILabel!
    @IBOutlet weak var shoutPrice: UILabel!
    @IBOutlet weak var shoutType: UILabel?
    @IBOutlet weak var shoutSubtitle: UILabel?
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
        self.name?.text = shout.user?.name
        
        if let publishedAt = shout.publishedAtEpoch, user = shout.user {
            self.shoutSubtitle?.text = "\(user.name) - \(DateFormatters.sharedInstance.stringFromDateEpoch(publishedAt))"
        } else if let user = shout.user {
            self.shoutSubtitle?.text = user.name
        }
        
        self.shoutPrice.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
        
        if let country = shout.location?.country, countryImage = UIImage(named:  country), countryImageView = self.shoutCountryImage {
            countryImageView.image = countryImage
        }
        
        if let path = shout.category.icon, url = path.toURL(), categoryImageView = self.shoutCategoryImage {
            categoryImageView.kf_setImageWithURL(url, placeholderImage: nil)
        }
        
        
        if let thumbPath = shout.thumbnailPath, thumbURL = NSURL(string: thumbPath) {
            self.shoutImage.sh_setImageWithURL(thumbURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        } else {
            self.shoutImage.image = UIImage(named:"auth_screen_bg_pattern")
        }
        
        self.shoutType?.text = shout.type()?.title()
        
    }
    
    func bindWith(DiscoverItem discoverItem: DiscoverItem) {
        self.shoutTitle.text = discoverItem.title
        
        if let imagePath = discoverItem.image, imageURL = NSURL(string: imagePath) {
            self.shoutImage.sh_setImageWithURL(imageURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        } else {
            self.shoutImage.image = UIImage(named:"auth_screen_bg_pattern")
        }
        
    }
    
    override func prepareForReuse() {
        self.shoutImage.image = nil
    }
}
