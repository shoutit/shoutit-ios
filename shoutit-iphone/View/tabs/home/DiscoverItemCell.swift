//
//  SHShoutItemCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit
import FBAudienceNetwork

class DiscoverItemCell: UICollectionViewCell {
    
    @IBOutlet weak var shoutImage: UIImageView?
    @IBOutlet weak var shoutTitle: UILabel?
    @IBOutlet weak var shoutBackgroundView: UIView?
}

extension DiscoverItemCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        self.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        self.layer.cornerRadius = 3.0
    }
    
    func bindWith(DiscoverItem discoverItem: DiscoverItem) {
        self.shoutTitle?.text = discoverItem.title
        
        if let imagePath = discoverItem.image, imageURL = NSURL(string: imagePath) {
            self.shoutImage?.sh_setImageWithURL(imageURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        } else {
            self.shoutImage?.image = UIImage(named:"auth_screen_bg_pattern")
        }
        
    }
    

    
    override func prepareForReuse() {
        super.prepareForReuse()
        shoutImage?.image = nil
        self.shoutTitle?.hidden = false
    }
    
}
