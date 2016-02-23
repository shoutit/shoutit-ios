//
//  SHShoutItemCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutItemCell: UICollectionViewCell {
    
    private var viewModel: SHShoutItemCellViewModel?
    @IBOutlet weak var shoutImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var shoutTitle: UILabel!
    @IBOutlet weak var shoutPrice: UILabel!
    @IBOutlet weak var shoutType: UILabel?
    @IBOutlet weak var shoutCountryImage: UIImageView?
    @IBOutlet weak var shoutCategoryImage: UIImageView?
}

extension SHShoutItemCell {
    
    func bindWith(Shout shout: Shout) {
        self.shoutTitle.text = shout.title
        
        if let publishedAt = shout.publishedAt {
            self.name.text = "\(shout.text) \(DateFormatters.sharedInstance.stringFromDateEpoch(publishedAt))"
        } else {
            self.name.text = shout.text
        }
        
        self.shoutPrice.text = "$\(shout.price)"
        
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
}
