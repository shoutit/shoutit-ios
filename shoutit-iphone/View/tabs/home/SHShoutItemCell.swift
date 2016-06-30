//
//  SHShoutItemCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class SHShoutItemCell: UICollectionViewCell {
    
    @IBOutlet weak var shoutImage: UIImageView?
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var shoutTitle: UILabel?
    @IBOutlet weak var shoutPrice: UILabel?
    @IBOutlet weak var shoutType: UILabel?
    @IBOutlet weak var shoutSubtitle: UILabel?
    @IBOutlet weak var shoutCountryImage: UIImageView?
    @IBOutlet weak var shoutCategoryImage: UIImageView?
    @IBOutlet weak var shoutBackgroundView: UIView?
    @IBOutlet weak var shoutPromotionBackground: UIView?
    @IBOutlet weak var shoutPromotionLabel: UILabel?
}

extension SHShoutItemCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        self.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        self.layer.cornerRadius = 3.0
        
        let (promotionView, promotionLabel) = createPromotionViews()
        
        self.shoutPromotionBackground = promotionView
        self.shoutPromotionLabel = promotionLabel
        
        self.shoutSubtitle?.hidden = false
        self.shoutPrice?.hidden = false
        self.name?.hidden = false
    }
    
    func bindWith(DiscoverItem discoverItem: DiscoverItem) {
        self.shoutTitle?.text = discoverItem.title
        
        if let imagePath = discoverItem.image, imageURL = NSURL(string: imagePath) {
            self.shoutImage?.sh_setImageWithURL(imageURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        } else {
            self.shoutImage?.image = UIImage(named:"auth_screen_bg_pattern")
        }
        
        self.shoutSubtitle?.hidden = true
        self.shoutPrice?.hidden = true
        self.name?.hidden = true
    }
    
    override func prepareForReuse() {
        self.shoutImage?.image = nil
    }
    
}
