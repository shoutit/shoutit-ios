//
//  PlcaholderCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class PlcaholderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var placeholderTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.hidden = true
    }
}
