//
//  ProfileCollectionShoutsCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutsCollectionViewCell: UICollectionViewCell {
    
    static let nibName = "ShoutsCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = 4
        layer.borderColor = UIColor(shoutitColor: .CellBackgroundGrayColor).CGColor
        layer.borderWidth = 1 / UIScreen.mainScreen().scale
    }
}
