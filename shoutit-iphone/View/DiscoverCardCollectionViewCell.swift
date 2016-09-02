//
//  DiscoverCardCollectionViewCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 01.09.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import QuartzCore
import ShoutitKit

class DiscoverCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView : UIImageView!
    
    @IBOutlet var firstLineLabel : UILabel!
    @IBOutlet var secondLineLabel : UILabel!
    
    @IBOutlet var shadowView : UIView!
    @IBOutlet var roundedContentView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shadowView.layer.shadowColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
        shadowView.layer.shadowOffset = CGSizeMake(1, 1)
        shadowView.layer.shadowRadius = 1.0
        shadowView.layer.cornerRadius = 2.0
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.mainScreen().nativeScale
        shadowView.clipsToBounds = false
        
        roundedContentView.layer.cornerRadius = 2.0
        roundedContentView.clipsToBounds = true
        roundedContentView.layer.borderWidth = 1.0 / UIScreen.mainScreen().nativeScale
        roundedContentView.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
    }

}

extension DiscoverCardCollectionViewCell : ReusableView, NibLoadableView {
    static var defaultReuseIdentifier: String { return "DiscoverCardCollectionViewCell" }
    static var nibName: String { return "DiscoverCard" }
}

extension DiscoverCardCollectionViewCell {
    func bindWithDiscoverItem(discoverItem: DiscoverItem) {
        fillLabel(self.firstLineLabel, withText: discoverItem.title)
        fillLabel(self.secondLineLabel, withText: discoverItem.subtitle)
        
        
        if let imagePath = discoverItem.image, imageURL = NSURL(string: imagePath) {
            self.imageView.sh_setImageWithURL(imageURL, placeholderImage: UIImage.backgroundPattern())
        } else {
            self.imageView.image = UIImage.backgroundPattern()
        }
        
    }
}