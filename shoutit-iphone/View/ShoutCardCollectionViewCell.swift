//
//  ShoutCardCollectionViewCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 30/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import QuartzCore

class ShoutCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView : UIImageView!
    
    @IBOutlet var firstLineLabel : UILabel!
    @IBOutlet var secondLineLabel : UILabel!
    @IBOutlet var thirdLineLabel : UILabel!
    
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

extension ShoutCardCollectionViewCell : ReusableView, NibLoadableView {
    static var defaultReuseIdentifier: String { return "ShoutCardCollectionViewCell" }
    static var nibName: String { return "ShoutCard" }
}
